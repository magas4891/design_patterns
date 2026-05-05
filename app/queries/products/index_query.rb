module Products
  class IndexQuery < ApplicationQuery
    SORT_OPTIONS = {
      "newest" => { created_at: :desc },
      "oldest" => { created_at: :asc },
      "price_asc" => { price_cents: :asc },
      "price_desc" => { price_cents: :desc }
    }.freeze

    def initialize(scope: Product.all, params: {})
      @scope = scope
      @params = params
    end

    def call
      relation = scope.includes(:category)
      relation = by_query(relation)
      relation = by_status(relation)
      relation = by_category(relation)
      relation = by_min_price(relation)
      relation = by_max_price(relation)
      relation.order(sort_option)
    end

    private

    attr_reader :scope, :params

    def by_query(relation)
      query = params[:q].to_s.strip
      return relation if query.blank?

      relation.where("products.name LIKE :q OR products.description LIKE :q", q: "%#{query}%")
    end

    def by_status(relation)
      return relation if params[:status].blank?

      relation.where(status: params[:status])
    end

    def by_category(relation)
      return relation if params[:category_id].blank?

      relation.where(category_id: params[:category_id])
    end

    def by_min_price(relation)
      return relation if params[:min_price_cents].blank?

      relation.where("products.price_cents >= ?", params[:min_price_cents].to_i)
    end

    def by_max_price(relation)
      return relation if params[:max_price_cents].blank?

      relation.where("products.price_cents <= ?", params[:max_price_cents].to_i)
    end

    def sort_option
      SORT_OPTIONS.fetch(params[:sort], SORT_OPTIONS["newest"])
    end
  end
end
