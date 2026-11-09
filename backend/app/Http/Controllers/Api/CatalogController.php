<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\ProductRequest;
use App\Http\Resources\CategoryResource;
use App\Http\Resources\ProductResource;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class CatalogController extends Controller
{
    public function categories(): AnonymousResourceCollection
    {
        return CategoryResource::collection(
            Category::withCount(['products' => fn ($q) => $q->active()])->orderBy('name')->get()
        );
    }

    public function products(Request $request): AnonymousResourceCollection
    {
        $request->validate([
            'q' => ['nullable', 'string', 'max:100'],
            'category' => ['nullable', 'string'],
            'min_price' => ['nullable', 'numeric', 'min:0'],
            'max_price' => ['nullable', 'numeric', 'min:0'],
            'sort' => ['nullable', 'in:newest,price_asc,price_desc,rating'],
            'per_page' => ['nullable', 'integer', 'between:1,50'],
        ]);

        $products = Product::with('category')
            ->active()
            ->when($request->q, fn ($q, $term) => $q->where(fn ($w) => $w
                ->where('name', 'like', "%{$term}%")
                ->orWhere('description', 'like', "%{$term}%")))
            ->when($request->category, fn ($q, $slug) => $q->whereHas('category', fn ($c) => $c->where('slug', $slug)))
            ->when($request->min_price, fn ($q, $min) => $q->where('price', '>=', $min))
            ->when($request->max_price, fn ($q, $max) => $q->where('price', '<=', $max));

        match ($request->input('sort', 'newest')) {
            'price_asc' => $products->orderBy('price'),
            'price_desc' => $products->orderByDesc('price'),
            'rating' => $products->orderByDesc('rating'),
            default => $products->latest(),
        };

        return ProductResource::collection($products->paginate($request->integer('per_page', 20))->withQueryString());
    }

    public function show(Product $product): ProductResource
    {
        abort_unless($product->is_active, 404);

        return new ProductResource($product->load('category'));
    }

    public function store(ProductRequest $request): JsonResponse
    {
        $product = Product::create($request->validated())->load('category');

        return (new ProductResource($product))->response()->setStatusCode(201);
    }

    public function update(ProductRequest $request, Product $product): ProductResource
    {
        $product->update($request->validated());

        return new ProductResource($product->load('category'));
    }

    public function destroy(Request $request, Product $product): JsonResponse
    {
        abort_unless($request->user()->isAdmin(), 403);
        $product->update(['is_active' => false]);

        return response()->json(null, 204);
    }
}
