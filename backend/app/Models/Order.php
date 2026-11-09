<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Order extends Model
{
    public const STATUSES = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];

    protected $fillable = [
        'number', 'user_id', 'status', 'subtotal', 'shipping', 'total', 'shipping_name',
        'shipping_phone', 'shipping_address', 'shipping_city', 'payment_method', 'notes',
    ];

    protected function casts(): array
    {
        return [
            'subtotal' => 'decimal:2',
            'shipping' => 'decimal:2',
            'total' => 'decimal:2',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    public function isCancellable(): bool
    {
        return $this->status === 'pending';
    }
}
