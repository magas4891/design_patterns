module Orders
  class OrderForm < ApplicationForm
    attribute :user_id, :integer
    attribute :status, :string
    attribute :total_cents, :integer
    attribute :placed_at, :datetime

    validates :user_id, :status, :total_cents, presence: true
    validates :total_cents, numericality: { greater_than_or_equal_to: 0 }

    def self.model_name
      ActiveModel::Name.new(self, nil, "Order")
    end

    def initialize(order:)
      @order = order
      super()
      sync_from_order
    end

    def submit(params = {})
      assign_attributes(normalize_params(params))
      return false unless valid?

      order.assign_attributes(
        user_id: user_id,
        status: status,
        total_cents: total_cents,
        placed_at: placed_at
      )

      if order.save
        true
      else
        errors.merge!(order.errors)
        false
      end
    end

    attr_reader :order

    private

    def sync_from_order
      self.user_id = order.user_id
      self.status = order.status
      self.total_cents = order.total_cents || 0
      self.placed_at = order.placed_at
    end

    def normalize_params(raw)
      h = raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw.to_h
      h = h.deep_symbolize_keys
      attrs = (h[:order] || h).symbolize_keys
      attrs[:user_id] = attrs[:user_id].to_i if attrs[:user_id].present?
      attrs[:total_cents] = attrs[:total_cents].to_i if attrs[:total_cents].present?
      if attrs[:placed_at].present?
        attrs[:placed_at] = parse_time(attrs[:placed_at])
      end
      attrs.slice(:user_id, :status, :total_cents, :placed_at)
    end

    def parse_time(value)
      Time.zone.parse(value.to_s)
    rescue ArgumentError, TypeError
      nil
    end
  end
end
