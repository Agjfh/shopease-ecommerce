# 🛍️ ShopEase: E-Commerce App

A full-stack shopping app: a **Flutter** storefront backed by a **Laravel 12 REST API**.

Customers browse and search the catalog, filter it by category, manage a cart that syncs with the server, check out with cash on delivery or card, and track their orders. Admins manage products and order status through the API.

## Features

**Mobile app (Flutter)**
- Product grid with search (debounced), category chips, and sorting
- Discount badges, stock warnings, and ratings
- Server-synced cart with a live badge, quantity controls, and a free-shipping progress hint
- Checkout form with shipping details and payment method
- Order history with a status tracker (pending → processing → shipped → delivered) and cancellation

**Backend (Laravel)**
- Sanctum token auth with rate-limited login and register
- Catalog API with filtering, search, sorting, and pagination
- Cart service that validates stock on every change
- **Transactional checkout** with row locks (`lockForUpdate`), so stock can't go negative under concurrent orders
- Order items store a price snapshot, so later price changes don't affect past orders
- Cancelling restores stock. Free shipping applies above EGP 1,000.
- Admin endpoints for products and order status
- Feature tests for filtering, cart rules, checkout, and cancellation

## Tech stack

| Layer | Tech |
|---|---|
| Mobile | Flutter 3, Dart, Provider, http, shared_preferences, intl |
| API | PHP 8.2+, Laravel 12, Sanctum |
| Database | SQLite (dev), MySQL / PostgreSQL ready |
| Tests | PHPUnit, flutter_test |

## Getting started

### Backend
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
touch database/database.sqlite
php artisan migrate --seed
php artisan serve
```
Demo accounts (password: `password`): `demo@shopease.test` (customer), `admin@shopease.test` (admin).

Run tests: `php artisan test`

### Mobile
```bash
cd mobile
flutter create . --project-name shopease --platforms android,ios
flutter pub get
flutter run --dart-define=API_URL=http://10.0.2.2:8000/api
```

## API endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/api/auth/register`, `/api/auth/login` | – | Auth |
| GET | `/api/categories` | – | Categories with product counts |
| GET | `/api/products?q=&category=&sort=price_asc` | – | Browse products |
| GET | `/api/products/{id}` | – | Product details |
| GET / POST / DELETE | `/api/cart` | ✔ | View, add to, or clear the cart |
| PATCH / DELETE | `/api/cart/{item}` | ✔ | Change quantity or remove an item |
| GET / POST | `/api/orders` | ✔ | Order history or checkout |
| GET | `/api/orders/{id}` | ✔ | Order details |
| POST | `/api/orders/{id}/cancel` | ✔ | Cancel a pending order |
| POST / PUT / DELETE | `/api/products` | Admin | Manage products |
| PATCH | `/api/orders/{id}/status` | Admin | Update order status |

## License

MIT
