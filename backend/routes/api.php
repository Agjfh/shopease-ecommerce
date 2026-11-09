<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\CatalogController;
use App\Http\Controllers\Api\OrderController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register'])->middleware('throttle:10,1');
    Route::post('login', [AuthController::class, 'login'])->middleware('throttle:10,1');

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('me', [AuthController::class, 'me']);
        Route::post('logout', [AuthController::class, 'logout']);
    });
});

Route::get('categories', [CatalogController::class, 'categories']);
Route::get('products', [CatalogController::class, 'products']);
Route::get('products/{product}', [CatalogController::class, 'show']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('cart', [CartController::class, 'index']);
    Route::post('cart', [CartController::class, 'store']);
    Route::patch('cart/{item}', [CartController::class, 'update']);
    Route::delete('cart/{item}', [CartController::class, 'destroy']);
    Route::delete('cart', [CartController::class, 'clear']);

    Route::get('orders', [OrderController::class, 'index']);
    Route::post('orders', [OrderController::class, 'store']);
    Route::get('orders/{order}', [OrderController::class, 'show']);
    Route::post('orders/{order}/cancel', [OrderController::class, 'cancel']);

    // Admin
    Route::post('products', [CatalogController::class, 'store']);
    Route::put('products/{product}', [CatalogController::class, 'update']);
    Route::delete('products/{product}', [CatalogController::class, 'destroy']);
    Route::patch('orders/{order}/status', [OrderController::class, 'updateStatus']);
});
