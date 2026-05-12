module Payments
  class CapturePaymentForm < ApplicationForm
    attribute :order_id, :integer
    attribute :source_token, :string
    attribute :provider, :string

    validates :order_id, numericality: { only_integer: true, greater_than: 0 }
    validates :source_token, presence: true

    def self.model_name
      ActiveModel::Name.new(self, nil, "CapturePayment")
    end

    def initialize(attributes = {})
      super()
      assign_attributes(attributes) if attributes.present?
    end

    def submit(params = {})
      assign_attributes(normalize_params(params))
      return false unless valid?

      order = Order.find_by(id: order_id)
      unless order
        errors.add(:order_id, "not found")
        return false
      end

      result = Payments::CaptureService.call(
        order: order,
        source_token: source_token.to_s.strip,
        provider: provider.presence || "fake_gateway"
      )

      if result.success?
        @payment = result.value
        true
      else
        errors.add(:base, result.error)
        false
      end
    end

    attr_reader :payment

    private

    def normalize_params(raw)
      h = raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw.to_h
      h = h.deep_symbolize_keys
      attrs = (h[:capture_payment] || h).symbolize_keys
      attrs[:order_id] = attrs[:order_id].to_i if attrs[:order_id].present?
      attrs.slice(:order_id, :source_token, :provider)
    end
  end
end
