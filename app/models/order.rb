class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_many :payments, dependent: :destroy

  validates :status, :total_cents, presence: true
  validates :total_cents, numericality: { greater_than_or_equal_to: 0 }

  enum :status, {
    cart: "cart",
    placed: "placed",
    paid: "paid",
    cancelled: "cancelled"
  }, default: :cart
end
