# Design Patterns Playground

This app is a sandbox for implementing and comparing Ruby on Rails design patterns.

## First services added

- `Orders::RecalculateTotalService` updates order total from order items.
- `Orders::PlaceService` validates and places cart orders.
- `Payments::CaptureService` performs payment capture flow and updates order/payment states.
- `Payments::FakeGateway` is an in-app payment gateway stub (no external API calls).

## Quick manual check

Use Rails console to run a happy-path flow:

```ruby
user = User.create!(name: "Demo", email: "demo@example.com", role: "customer", status: "active")
category = Category.create!(name: "Books", slug: "books")
product = Product.create!(name: "DDD", description: "Domain-Driven Design", price_cents: 5000, status: "active", category: category)
order = Order.create!(user: user, status: "cart", total_cents: 0)
OrderItem.create!(order: order, product: product, quantity: 2, unit_price_cents: product.price_cents)

Orders::PlaceService.call(order: order)
Payments::CaptureService.call(order: order.reload, source_token: "ok")
```
