module Payments
  class IndexQuery < ApplicationQuery
    SORT_OPTIONS = {
      "newest" => { created_at: :desc },
      "oldest" => { created_at: :asc },
      "amount_asc" => { amount_cents: :asc },
      "amount_desc" => { amount_cents: :desc }
    }.freeze

    def initialize(scope: Payment.all, params: {})
      @scope = scope
      @params = params
    end

    def call
      relation = scope.includes(order: :user)
      relation = by_status(relation)
      relation = by_provider(relation)
      relation = by_order(relation)
      relation = by_paid_from(relation)
      relation = by_paid_to(relation)
      relation.order(sort_option)
    end

    private

    attr_reader :scope, :params

    def by_status(relation)
      return relation if params[:status].blank?

      relation.where(status: params[:status])
    end

    def by_provider(relation)
      return relation if params[:provider].blank?

      relation.where(provider: params[:provider])
    end

    def by_order(relation)
      return relation if params[:order_id].blank?

      relation.where(order_id: params[:order_id])
    end

    def by_paid_from(relation)
      return relation if params[:paid_from].blank?

      relation.where("payments.paid_at >= ?", Time.zone.parse(params[:paid_from]))
    rescue ArgumentError, TypeError
      relation
    end

    def by_paid_to(relation)
      return relation if params[:paid_to].blank?

      relation.where("payments.paid_at <= ?", Time.zone.parse(params[:paid_to]))
    rescue ArgumentError, TypeError
      relation
    end

    def sort_option
      SORT_OPTIONS.fetch(params[:sort], SORT_OPTIONS["newest"])
    end
  end
end
