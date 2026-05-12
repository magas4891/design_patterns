module Products
  class ProductForm < ApplicationForm
    attribute :name, :string
    attribute :description, :string
    attribute :price_cents, :integer
    attribute :status, :string
    attribute :category_id, :integer

    validates :name, :price_cents, :category_id, presence: true
    validates :price_cents, numericality: { greater_than_or_equal_to: 0 }

    def self.model_name
      ActiveModel::Name.new(self, nil, "Product")
    end

    def initialize(product:)
      @product = product
      super()
      sync_from_product
    end

    def submit(params = {})
      assign_attributes(normalize_params(params))
      return false unless valid?

      product.assign_attributes(
        name: name,
        description: description,
        price_cents: price_cents,
        status: status.presence || "draft",
        category_id: category_id
      )

      if product.save
        true
      else
        errors.merge!(product.errors)
        false
      end
    end

    attr_reader :product

    private

    def sync_from_product
      self.name = product.name
      self.description = product.description
      self.price_cents = product.price_cents || 0
      self.status = product.status
      self.category_id = product.category_id
    end

    def normalize_params(raw)
      h = raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw.to_h
      h = h.deep_symbolize_keys
      attrs = (h[:product] || h).symbolize_keys
      if attrs[:category_id].present?
        attrs[:category_id] = attrs[:category_id].to_i
      end
      if attrs[:price_cents].present?
        attrs[:price_cents] = attrs[:price_cents].to_i
      end
      attrs.slice(:name, :description, :price_cents, :status, :category_id)
    end
  end
end
