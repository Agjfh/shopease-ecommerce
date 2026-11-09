<?php

namespace App\Services;

use App\Exceptions\ShopException;
use App\Models\CartItem;
use App\Models\Product;
use App\Models\User;
use Illuminate\Support\Collection;

class CartService
{
    public const FREE_SHIPPING_FROM = 1000;

    public const SHIPPING_FEE = 60;

    /** @return Collection<int, CartItem> */
    public function items(User $user): Collection
    {
        return $user->cartItems()->with('product.category')->latest()->get();
    }

    public function add(User $user, Product $product, int $quantity): CartItem
    {
        if (! $product->is_active) {
            throw new ShopException('This product is not available.');
        }

        $item = $user->cartItems()->firstOrNew(['product_id' => $product->id]);
        $newQuantity = ($item->exists ? $item->quantity : 0) + $quantity;

        $this->ensureStock($product, $newQuantity);

        $item->quantity = $newQuantity;
        $item->save();

        return $item->load('product');
    }

    public function update(CartItem $item, int $quantity): CartItem
    {
        $this->ensureStock($item->product, $quantity);
        $item->update(['quantity' => $quantity]);

        return $item->load('product');
    }

    /** @return array{subtotal: float, shipping: float, total: float, count: int} */
    public function totals(Collection $items): array
    {
        $subtotal = round($items->sum(fn (CartItem $i) => $i->product->price * $i->quantity), 2);
        $shipping = ($subtotal === 0.0 || $subtotal >= self::FREE_SHIPPING_FROM) ? 0.0 : (float) self::SHIPPING_FEE;

        return [
            'subtotal' => $subtotal,
            'shipping' => $shipping,
            'total' => round($subtotal + $shipping, 2),
            'count' => (int) $items->sum('quantity'),
        ];
    }

    private function ensureStock(Product $product, int $quantity): void
    {
        if ($quantity > $product->stock) {
            throw new ShopException("Only {$product->stock} of \"{$product->name}\" left in stock.");
        }
    }
}
