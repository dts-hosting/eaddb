module Filterable
  extend ActiveSupport::Concern

  def apply_filters(scope, params)
    scope = scope.order(order_by) if respond_to?(:order_by, true)

    if params[:query].present? && respond_to?(:query_filter, true)
      scope = query_filter(scope, params[:query])
    end

    if params[:collection].present? && respond_to?(:collection_filter, true)
      scope = collection_filter(scope, params[:collection])
    end

    if params[:status].present?
      scope = scope.where(status: params[:status])
    end

    scope
  end

  def filter_params_present?
    params[:query].present? || params[:collection].present? || params[:status].present?
  end
end
