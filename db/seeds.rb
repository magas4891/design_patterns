# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user = User.create!(name: "Demo", email: "demo@example.com", role: "customer", status: "active")
category = Category.create!(name: "Books", slug: "books")
product = Product.create!(name: "DDD", description: "Domain-Driven Design", price_cents: 5000, status: "active", category: category)
order = Order.create!(user: user, status: "cart", total_cents: 0)
OrderItem.create!(order: order, product: product, quantity: 2, unit_price_cents: product.price_cents)

Orders::PlaceService.call(order: order)
Payments::CaptureService.call(order: order.reload, source_token: "ok")
