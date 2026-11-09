<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\CartItemResource;
use App\Models\CartItem;
use App\Models\Product;
use App\Services\CartService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function __construct(private readonly CartService $cart)
    {
    }

    public function index(Request $request): JsonResponse
    {
        return $this->cartResponse($request);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'product_id' => ['required', 'integer', 'exists:products,id'],
            'quantity' => ['nullable', 'integer', 'min:1', 'max:99'],
        ]);

        $this->cart->add($request->user(), Product::findOrFail($data['product_id']), $data['quantity'] ?? 1);

        return $this->cartResponse($request, 201);
    }

    public function update(Request $request, CartItem $item): JsonResponse
    {
        $this->authorizeItem($request, $item);
        $data = $request->validate(['quantity' => ['required', 'integer', 'min:1', 'max:99']]);

        $this->cart->update($item, $data['quantity']);

        return $this->cartResponse($request);
    }

    public function destroy(Request $request, CartItem $item): JsonResponse
    {
        $this->authorizeItem($request, $item);
        $item->delete();

        return $this->cartResponse($request);
    }

    public function clear(Request $request): JsonResponse
    {
        $request->user()->cartItems()->delete();

        return $this->cartResponse($request);
    }

    private function authorizeItem(Request $request, CartItem $item): void
    {
        abort_unless($item->user_id === $request->user()->id, 404);
    }

    private function cartResponse(Request $request, int $status = 200): JsonResponse
    {
        $items = $this->cart->items($request->user());

        return response()->json([
            'items' => CartItemResource::collection($items),
            'summary' => $this->cart->totals($items) + [
                'free_shipping_from' => CartService::FREE_SHIPPING_FROM,
            ],
        ], $status);
    }
}
