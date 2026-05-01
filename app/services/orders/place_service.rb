module Orders
  class PlaceService < ApplicationService
    def initialize(order:)
      @order = order
    end

    def call
      return failure("Only cart orders can be placed") unless order.cart?
      return failure("Order must have at least one item") if order.order_items.empty?

      Order.transaction do
        total_result = Orders::RecalculateTotalService.call(order: order)
        raise StandardError, total_result.error unless total_result.success?

        order.update!(status: :placed, placed_at: Time.current)
      end

      success(order.reload)
    rescue ActiveRecord::ActiveRecordError => e
      failure(e.message)
    end

    private

    attr_reader :order
  end
end
