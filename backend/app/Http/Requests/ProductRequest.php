<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->isAdmin();
    }

    public function rules(): array
    {
        $required = $this->isMethod('post') ? 'required' : 'sometimes';

        return [
            'category_id' => [$required, 'integer', 'exists:categories,id'],
            'name' => [$required, 'string', 'max:255'],
            'description' => [$required, 'string'],
            'price' => [$required, 'numeric', 'min:0'],
            'compare_at_price' => ['nullable', 'numeric', 'gt:price'],
            'stock' => [$required, 'integer', 'min:0'],
            'image_url' => ['nullable', 'url'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}
