<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        User::factory()->admin()->create(['name' => 'Store Admin', 'email' => 'admin@shopease.test']);
        User::factory()->create(['name' => 'Demo Customer', 'email' => 'demo@shopease.test']);

        $catalog = [
            ['Electronics', 'devices', [
                ['Wireless Earbuds Pro', 'Active noise cancellation, 30-hour battery with case, IPX5 water resistance.', 1899, 2299],
                ['Smart Watch S3', 'Heart-rate and sleep tracking, GPS, 7-day battery and AMOLED display.', 3450, null],
                ['Power Bank 20,000mAh', 'Fast charging 22.5W with USB-C PD, charges two devices at once.', 899, 1099],
                ['Bluetooth Speaker Mini', 'Pocket-size speaker with deep bass and 12 hours of playtime.', 749, null],
            ]],
            ['Fashion', 'checkroom', [
                ['Classic Cotton T-Shirt', '100% Egyptian cotton, regular fit, available in 6 colors.', 299, 399],
                ['Slim Fit Jeans', 'Stretch denim with a modern slim fit for all-day comfort.', 850, null],
                ['Running Sneakers', 'Lightweight mesh upper and cushioned sole for daily runs.', 1650, 1950],
            ]],
            ['Home & Kitchen', 'kitchen', [
                ['Air Fryer 5L', 'Crispy results with 80% less oil, 8 presets and a digital touch panel.', 2799, 3299],
                ['Ceramic Coffee Mug Set', 'Set of 4 handmade ceramic mugs, 350ml each, dishwasher safe.', 420, null],
                ['Electric Kettle 1.7L', 'Stainless steel kettle with auto shut-off and boil-dry protection.', 690, null],
            ]],
            ['Books', 'menu_book', [
                ['Clean Code', 'A handbook of agile software craftsmanship by Robert C. Martin.', 550, null],
                ['Atomic Habits', 'An easy and proven way to build good habits and break bad ones.', 380, 450],
            ]],
        ];

        foreach ($catalog as $i => [$name, $icon, $products]) {
            $category = Category::create(['name' => $name, 'slug' => Str::slug($name), 'icon' => $icon]);

            foreach ($products as $j => [$title, $description, $price, $compare]) {
                Product::create([
                    'category_id' => $category->id,
                    'name' => $title,
                    'description' => $description,
                    'price' => $price,
                    'compare_at_price' => $compare,
                    'stock' => [25, 8, 0, 40, 3][($i + $j) % 5],
                    'image_url' => 'https://picsum.photos/seed/'.Str::slug($title).'/600/600',
                    'rating' => [4.8, 4.5, 4.2, 4.6, 3.9][($i + $j) % 5],
                ]);
            }
        }
    }
}
