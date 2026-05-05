module Users
  class IndexQuery < ApplicationQuery
    SORT_OPTIONS = {
      "newest" => { created_at: :desc },
      "oldest" => { created_at: :asc },
      "name_asc" => { name: :asc },
      "name_desc" => { name: :desc }
    }.freeze

    def initialize(scope: User.all, params: {})
      @scope = scope
      @params = params
    end

    def call
      relation = scope
      relation = by_query(relation)
      relation = by_role(relation)
      relation = by_status(relation)
      relation.order(sort_option)
    end

    private

    attr_reader :scope, :params

    def by_query(relation)
      query = params[:q].to_s.strip
      return relation if query.blank?

      relation.where("users.name LIKE :q OR users.email LIKE :q", q: "%#{query}%")
    end

    def by_role(relation)
      return relation if params[:role].blank?

      relation.where(role: params[:role])
    end

    def by_status(relation)
      return relation if params[:status].blank?

      relation.where(status: params[:status])
    end

    def sort_option
      SORT_OPTIONS.fetch(params[:sort], SORT_OPTIONS["newest"])
    end
  end
end
