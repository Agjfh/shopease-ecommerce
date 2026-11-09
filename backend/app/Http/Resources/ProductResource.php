<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,
            'price' => (float) $this->price,
            'compare_at_price' => $this->compare_at_price ? (float) $this->compare_at_price : null,
            'discount_percent' => $this->discountPercent(),
            'stock' => $this->stock,
            'in_stock' => $this->stock > 0,
            'image_url' => $this->image_url,
            'rating' => (float) $this->rating,
            'category' => new CategoryResource($this->whenLoaded('category')),
        ];
    }
}
