json.extract! product, :id, :name, :description, :price_cents, :status, :category_id, :created_at, :updated_at
json.url product_url(product, format: :json)
