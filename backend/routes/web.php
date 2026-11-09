<?php

use Illuminate\Support\Facades\Route;

Route::get('/', fn () => response()->json([
    'name' => 'ShopEase API',
    'status' => 'ok',
]));
