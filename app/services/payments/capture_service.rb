module Payments
  class CaptureService < ApplicationService
    def initialize(order:, source_token:, provider: "fake_gateway")
      @order = order
      @source_token = source_token
      @provider = provider
      @gateway = Payments::FakeGateway.new
    end

    def call
      return failure("Order must be placed before payment") unless order.placed?

      payment = order.payments.create!(
        provider: provider,
        status: :pending,
        amount_cents: order.total_cents
      )

      gateway_response = gateway.capture(
        amount_cents: payment.amount_cents,
        source_token: source_token
      )

      if gateway_response.success?
        payment.update!(status: :captured, transaction_id: gateway_response.transaction_id, paid_at: Time.current)
        order.update!(status: :paid)
        success(payment)
      else
        payment.update!(status: :failed)
        failure(gateway_response.error)
      end
    rescue ActiveRecord::ActiveRecordError => e
      failure(e.message)
    end

    private

    attr_reader :order, :source_token, :provider, :gateway
  end
end
