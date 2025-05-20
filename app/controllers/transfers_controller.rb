class TransfersController < ApplicationController
  include Filterable

  def index
    transfers = apply_filters(
      Transfer.includes(:destination, :record).latest_active, params
    )
    @pagy, @transfers = pagy(transfers, limit: 20)
  end

  private

  def order_by
    {updated_at: :desc}
  end

  def query_filter(scope, query)
    scope.joins(:record).where("records.ead_identifier LIKE ?", "%#{query}%")
  end
end
