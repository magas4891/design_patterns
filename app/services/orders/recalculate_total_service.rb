module Orders
  class RecalculateTotalService < ApplicationService
    def initialize(order:)
      @order = order
    end

    def call
      total_cents = order.order_items.sum("quantity * unit_price_cents")
      order.update!(total_cents: total_cents)

      success(order)
    rescue ActiveRecord::ActiveRecordError => e
      failure(e.message)
    end

    private

    attr_reader :order
  end
end
