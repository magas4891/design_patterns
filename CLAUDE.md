# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

Rails 8.1 sandbox for implementing and comparing Ruby on Rails design patterns. Uses SQLite with Ruby 3.2.1.

## Commands

```bash
bin/rails server          # start dev server
bin/rails console         # Rails console
bin/rails db:migrate      # run migrations
bin/rails db:seed         # seed the database

bin/rubocop               # lint (rubocop-rails-omakase style)
bin/brakeman --no-pager   # static security analysis
bin/bundler-audit         # gem vulnerability audit
bin/importmap audit       # JS dependency audit
```

## Architecture

This app demonstrates four patterns, each in its own layer under `app/`:

### Service Objects (`app/services/`)

Inherit from `ApplicationService`. Call via `ServiceName.call(...)`. Returns a `Result` struct with `success?`, `value`, and `error`.

```ruby
result = Orders::PlaceService.call(order: order)
result.success? # => true/false
result.value    # => the order
result.error    # => error string on failure
```

Services own business logic and state transitions. `Orders::PlaceService` delegates to `Orders::RecalculateTotalService` inside a transaction. `Payments::CaptureService` uses `Payments::FakeGateway` (stub — no real API calls; pass `source_token: "ok"` to succeed, `"fail"` to fail).

### Query Objects (`app/queries/`)

Inherit from `ApplicationQuery`. Call via `QueryName.call(params: ...)`. Return an AR relation (not an array). Accept a `scope:` kwarg for composability and a `params:` hash for filtering/sorting. Used in controller `index` actions.

### Form Objects (`app/forms/`)

Inherit from `ApplicationForm` (`ActiveModel::Model` + `ActiveModel::Attributes`). Interface: instantiate with a model, call `form.submit(params)` → returns `true`/`false`. Errors are on the form object.

Controllers use forms for new/create/edit/update. The pattern:
```ruby
@form = Products::ProductForm.new(product: @product)
@form.submit(product_params)  # returns bool; @form.errors on failure
```

`Payments::CapturePaymentForm` is special: on `submit` it delegates to `Payments::CaptureService` instead of writing AR directly. Exposes `@form.payment` after a successful capture.

### Domain Models (`app/models/`)

Thin AR models — validations and associations only, no business logic. Key enums:
- `Order.status`: `cart → placed → paid / cancelled`
- `Product.status`: `draft / active / archived`
- `Payment.status`: `pending → captured / failed / refunded`

Prices/amounts are stored as integer cents (`price_cents`, `amount_cents`, `total_cents`).

### Decorators (`app/decorators/`)

Inherit from `ApplicationDecorator` (`SimpleDelegator`). Controllers wrap models in `show` and `index` only — `edit`/`update`/`create` use raw AR objects so form objects work correctly.

```ruby
# single object
@product = ProductDecorator.decorate(@product)

# collection (called on the AR relation result)
@products = ProductDecorator.decorate_collection(Products::IndexQuery.call(...))
```

`ApplicationDecorator` overrides `to_partial_path` and `model_name` to delegate to the underlying object, so `render @product` still resolves to `app/views/products/_product.html.erb`.

Decorated methods per class:
- `ProductDecorator` — `formatted_price`, `status_label`, `category_name`
- `OrderDecorator` — `formatted_total`, `formatted_placed_at`, `status_label`, `user_name`
- `PaymentDecorator` — `formatted_amount`, `formatted_paid_at`, `status_label`
- `UserDecorator` — `role_label`, `status_label`

## Happy-path flow (console)

```ruby
user     = User.create!(name: "Demo", email: "demo@example.com", role: "customer", status: "active")
category = Category.create!(name: "Books", slug: "books")
product  = Product.create!(name: "DDD", price_cents: 5000, status: "active", category: category)
order    = Order.create!(user: user, status: "cart", total_cents: 0)
OrderItem.create!(order: order, product: product, quantity: 2, unit_price_cents: product.price_cents)

Orders::PlaceService.call(order: order)
Payments::CaptureService.call(order: order.reload, source_token: "ok")
```
