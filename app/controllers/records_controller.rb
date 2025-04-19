class RecordsController < ApplicationController
  def index
    records = Record.none

    if params[:query].present? || params[:status].present?
      records = Record.all

      if params[:query].present?
        records = records.where(
          "records.ead_identifier LIKE ?", "%#{params[:query]}%"
        )
      end

      if params[:status].present?
        records = records.where(status: params[:status])
      end
    end

    @pagy, @records = pagy(records, limit: 20)
  end
end
