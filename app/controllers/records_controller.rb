class RecordsController < ApplicationController
  include Filterable

  before_action :set_record, only: [:show, :resend, :withdraw]

  def index
    records = if filter_params_present?
      apply_filters(Record.all, params)
    else
      Record.none
    end

    @pagy, @records = pagy(records, limit: 20)
  end

  def untransferables
    @pagy, @records = pagy(Record.untransferables, limit: 20)
  end

  def show
    @pagy, @transfers = pagy(@record.transfers.order(created_at: :desc), limit: 5)
  end

  # record tools
  def resend
    if @record.transferable?
      @record.queue_export
      redirect_to record_path(@record)
    else
      redirect_to record_path(@record), alert: "Cannot transfer failed record."
    end
  end

  def withdraw
    if @record.transferable?
      @record.queue_withdraw
      redirect_to record_path(@record)
    else
      redirect_to record_path(@record), alert: "Cannot withdraw failed record."
    end
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

  def set_record
    @record = Record.find(params[:id])
  end
end
