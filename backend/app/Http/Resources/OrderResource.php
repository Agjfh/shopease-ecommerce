<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'number' => $this->number,
            'status' => $this->status,
            'subtotal' => (float) $this->subtotal,
            'shipping' => (float) $this->shipping,
            'total' => (float) $this->total,
            'payment_method' => $this->payment_method,
            'shipping_address' => [
                'name' => $this->shipping_name,
                'phone' => $this->shipping_phone,
                'address' => $this->shipping_address,
                'city' => $this->shipping_city,
            ],
            'notes' => $this->notes,
            'can_cancel' => $this->isCancellable(),
            'items' => $this->whenLoaded('items', fn () => $this->items->map(fn ($item) => [
                'product_id' => $item->product_id,
                'name' => $item->product_name,
                'unit_price' => (float) $item->unit_price,
                'quantity' => $item->quantity,
                'line_total' => (float) $item->line_total,
            ])),
            'created_at' => $this->created_at->toIso8601String(),
        ];
    }
}
