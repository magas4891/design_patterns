class Category < ApplicationRecord
  has_many :products, dependent: :restrict_with_exception

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true
end
