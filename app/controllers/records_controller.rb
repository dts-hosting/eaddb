class RecordsController < ApplicationController
  include Filterable

  def index
    records = if filter_params_present?
      apply_filters(Record.all, params)
    else
      Record.none
    end

    @pagy, @records = pagy(records, limit: 20)
  end

  private

  def collection_filter(scope, collection_name)
    scope.joins(:collection).where("collections.name LIKE ?", "%#{collection_name}%")
  end

  def order_by
    :ead_identifier
  end

  def query_filter(scope, query)
    scope.where("records.ead_identifier LIKE ?", "%#{query}%")
  end
end
