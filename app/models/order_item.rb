class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, :unit_price_cents, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }
end
