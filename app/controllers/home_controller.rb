class HomeController < ApplicationController
  def index
    @pagy, @transfers = pagy(Transfer.includes(:destination, :record).order(updated_at: :desc))
  end
end
