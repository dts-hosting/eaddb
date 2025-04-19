class TransfersController < ApplicationController
  def index
    transfers = Transfer.includes(:destination, :record).order(updated_at: :desc)

    if params[:query].present?
      transfers = transfers.joins(:record).where(
        "records.ead_identifier LIKE ?", "%#{params[:query]}%"
      )
    end

    @pagy, @transfers = pagy(transfers, limit: 20)
  end
end
