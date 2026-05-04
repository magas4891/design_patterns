class Payment < ApplicationRecord
  belongs_to :order

  validates :provider, :status, :amount_cents, presence: true
  validates :amount_cents, numericality: { greater_than: 0 }

  enum :status, {
    pending: "pending",
    captured: "captured",
    failed: "failed",
    refunded: "refunded"
  }, default: :pending
end
