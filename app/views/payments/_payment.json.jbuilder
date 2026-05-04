json.extract! payment, :id, :order_id, :provider, :status, :amount_cents, :transaction_id, :paid_at, :created_at, :updated_at
json.url payment_url(payment, format: :json)
