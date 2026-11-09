<?php

namespace App\Services;

use App\Exceptions\ShopException;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class CheckoutService
{
    public function __construct(private readonly CartService $cart)
    {
    }

    /**
     * Turns the user's cart into an order. Product rows are locked so
     * stock can never go negative when many people check out at once.
     *
     * @param  array<string, string|null>  $shipping
     */
    public function checkout(User $user, array $shipping): Order
    {
        return DB::transaction(function () use ($user, $shipping) {
            $items = $user->cartItems()->get();

            if ($items->isEmpty()) {
                throw new ShopException('Your cart is empty.');
            }

            $products = Product::whereIn('id', $items->pluck('product_id'))
                ->lockForUpdate()
                ->get()
                ->keyBy('id');

            foreach ($items as $item) {
                $product = $products[$item->product_id];
                if (! $product->is_active || $product->stock < $item->quantity) {
                    throw new ShopException("Sorry, \"{$product->name}\" doesn't have enough stock anymore.");
                }
                $item->setRelation('product', $product);
            }

            $totals = $this->cart->totals($items);

            $order = $user->orders()->create([
                'number' => 'SE-'.now()->format('ymd').'-'.strtoupper(Str::random(5)),
                'status' => 'pending',
                'subtotal' => $totals['subtotal'],
                'shipping' => $totals['shipping'],
                'total' => $totals['total'],
                'shipping_name' => $shipping['shipping_name'],
                'shipping_phone' => $shipping['shipping_phone'],
                'shipping_address' => $shipping['shipping_address'],
                'shipping_city' => $shipping['shipping_city'],
                'payment_method' => $shipping['payment_method'] ?? 'cash_on_delivery',
                'notes' => $shipping['notes'] ?? null,
            ]);

            foreach ($items as $item) {
                $product = $item->product;
                $order->items()->create([
                    'product_id' => $product->id,
                    'product_name' => $product->name,
                    'unit_price' => $product->price,
                    'quantity' => $item->quantity,
                    'line_total' => round($product->price * $item->quantity, 2),
                ]);
                $product->decrement('stock', $item->quantity);
            }

            $user->cartItems()->delete();

            return $order->load('items');
        });
    }

    public function cancel(Order $order): Order
    {
        if (! $order->isCancellable()) {
            throw new ShopException('Only pending orders can be cancelled.');
        }

        return DB::transaction(function () use ($order) {
            foreach ($order->items as $item) {
                if ($item->product_id) {
                    Product::whereKey($item->product_id)->increment('stock', $item->quantity);
                }
            }
            $order->update(['status' => 'cancelled']);

            return $order->fresh('items');
        });
    }
}
