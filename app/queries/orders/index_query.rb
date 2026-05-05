module Orders
  class IndexQuery < ApplicationQuery
    SORT_OPTIONS = {
      "newest" => { placed_at: :desc },
      "oldest" => { placed_at: :asc },
      "total_asc" => { total_cents: :asc },
      "total_desc" => { total_cents: :desc }
    }.freeze

    def initialize(scope: Order.all, params: {})
      @scope = scope
      @params = params
    end

    def call
      relation = scope.includes(:user)
      relation = by_status(relation)
      relation = by_user(relation)
      relation = by_placed_from(relation)
      relation = by_placed_to(relation)
      relation.order(sort_option)
    end

    private

    attr_reader :scope, :params

    def by_status(relation)
      return relation if params[:status].blank?

      relation.where(status: params[:status])
    end

    def by_user(relation)
      return relation if params[:user_id].blank?

      relation.where(user_id: params[:user_id])
    end

    def by_placed_from(relation)
      return relation if params[:placed_from].blank?

      relation.where("orders.placed_at >= ?", Time.zone.parse(params[:placed_from]))
    rescue ArgumentError, TypeError
      relation
    end

    def by_placed_to(relation)
      return relation if params[:placed_to].blank?

      relation.where("orders.placed_at <= ?", Time.zone.parse(params[:placed_to]))
    rescue ArgumentError, TypeError
      relation
    end

    def sort_option
      SORT_OPTIONS.fetch(params[:sort], SORT_OPTIONS["newest"])
    end
  end
end
