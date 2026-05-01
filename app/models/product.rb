class Product < ApplicationRecord
  belongs_to :category
  has_many :order_items, dependent: :restrict_with_exception
  has_many :orders, through: :order_items

  validates :name, :price_cents, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }

  enum :status, { draft: "draft", active: "active", archived: "archived" }, default: :draft
end
