<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CheckoutTest extends TestCase
{
    use RefreshDatabase;

    private function product(array $overrides = []): Product
    {
        $category = Category::firstOrCreate(['slug' => 'devices'], ['name' => 'Devices']);

        return Product::create(array_merge([
            'category_id' => $category->id,
            'name' => 'Wireless Earbuds',
            'description' => 'Great sound.',
            'price' => 400,
            'stock' => 5,
        ], $overrides));
    }

    private function shipping(): array
    {
        return [
            'shipping_name' => 'Ahmed Amr',
            'shipping_phone' => '01000000000',
            'shipping_address' => '12 Street, District 3',
            'shipping_city' => 'Cairo',
        ];
    }

    public function test_products_can_be_filtered_by_category_and_search(): void
    {
        $this->product(['name' => 'Wireless Earbuds']);
        $this->product(['name' => 'Smart Watch']);

        $this->getJson('/api/products?category=devices&q=watch')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'Smart Watch');
    }

    public function test_adding_the_same_product_twice_increases_quantity(): void
    {
        $product = $this->product();
        $user = User::factory()->create();

        $this->actingAs($user)->postJson('/api/cart', ['product_id' => $product->id, 'quantity' => 2]);
        $this->actingAs($user)->postJson('/api/cart', ['product_id' => $product->id])
            ->assertCreated()
            ->assertJsonPath('items.0.quantity', 3)
            ->assertJsonPath('summary.subtotal', 1200);
    }

    public function test_cannot_add_more_than_stock(): void
    {
        $product = $this->product(['stock' => 2]);

        $this->actingAs(User::factory()->create())
            ->postJson('/api/cart', ['product_id' => $product->id, 'quantity' => 3])
            ->assertUnprocessable();
    }

    public function test_checkout_creates_order_reduces_stock_and_clears_cart(): void
    {
        $product = $this->product(['price' => 400, 'stock' => 5]);
        $user = User::factory()->create();

        $this->actingAs($user)->postJson('/api/cart', ['product_id' => $product->id, 'quantity' => 2]);

        $this->actingAs($user)->postJson('/api/orders', $this->shipping())
            ->assertCreated()
            ->assertJsonPath('subtotal', 800)
            ->assertJsonPath('shipping', 60)
            ->assertJsonPath('total', 860)
            ->assertJsonPath('status', 'pending');

        $this->assertSame(3, $product->fresh()->stock);
        $this->assertSame(0, $user->cartItems()->count());
    }

    public function test_cancelling_an_order_restores_stock(): void
    {
        $product = $this->product(['stock' => 5]);
        $user = User::factory()->create();

        $this->actingAs($user)->postJson('/api/cart', ['product_id' => $product->id, 'quantity' => 2]);
        $orderId = $this->actingAs($user)->postJson('/api/orders', $this->shipping())->json('id');

        $this->actingAs($user)->postJson("/api/orders/{$orderId}/cancel")
            ->assertOk()
            ->assertJsonPath('status', 'cancelled');

        $this->assertSame(5, $product->fresh()->stock);
    }

    public function test_checkout_with_empty_cart_fails(): void
    {
        $this->actingAs(User::factory()->create())
            ->postJson('/api/orders', $this->shipping())
            ->assertUnprocessable();
    }
}
