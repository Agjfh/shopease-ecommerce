<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\CheckoutRequest;
use App\Http\Resources\OrderResource;
use App\Models\Order;
use App\Services\CheckoutService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Validation\Rule;

class OrderController extends Controller
{
    public function __construct(private readonly CheckoutService $checkout)
    {
    }

    public function index(Request $request): AnonymousResourceCollection
    {
        $query = $request->user()->isAdmin() && $request->boolean('all')
            ? Order::query()
            : $request->user()->orders();

        return OrderResource::collection($query->with('items')->latest()->paginate(15));
    }

    public function store(CheckoutRequest $request): JsonResponse
    {
        $order = $this->checkout->checkout($request->user(), $request->validated());

        return (new OrderResource($order))->response()->setStatusCode(201);
    }

    public function show(Request $request, Order $order): OrderResource
    {
        $this->authorizeOrder($request, $order);

        return new OrderResource($order->load('items'));
    }

    public function cancel(Request $request, Order $order): OrderResource
    {
        $this->authorizeOrder($request, $order);

        return new OrderResource($this->checkout->cancel($order->load('items')));
    }

    public function updateStatus(Request $request, Order $order): OrderResource
    {
        abort_unless($request->user()->isAdmin(), 403);
        $data = $request->validate(['status' => ['required', Rule::in(Order::STATUSES)]]);

        if ($data['status'] === 'cancelled') {
            return new OrderResource($this->checkout->cancel($order->load('items')));
        }

        $order->update($data);

        return new OrderResource($order->load('items'));
    }

    private function authorizeOrder(Request $request, Order $order): void
    {
        abort_unless($order->user_id === $request->user()->id || $request->user()->isAdmin(), 404);
    }
}
