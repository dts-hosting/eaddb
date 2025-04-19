class RecordsController < ApplicationController
  def index
    records = Record.none

    if params[:query].present?
      records = Record.where(
        "records.ead_identifier LIKE ?", "%#{params[:query]}%"
      )
    end

    @pagy, @records = pagy(records, limit: 20)
  end
end
