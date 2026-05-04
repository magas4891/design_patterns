class User < ApplicationRecord
  has_many :orders, dependent: :destroy

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  enum :role, { customer: "customer", admin: "admin" }, default: :customer
  enum :status, { active: "active", inactive: "inactive" }, default: :active
end
