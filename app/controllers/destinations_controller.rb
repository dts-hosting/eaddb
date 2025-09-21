class DestinationsController < ApplicationController
  before_action :set_collection, only: [:new, :create]
  before_action :set_destination, only: [:show, :edit, :update, :destroy, :reset, :run]

  def index
    destinations = Destination.includes(:collection).order(:name)

    if params[:query].present?
      destinations = destinations.where("name LIKE ?", "%#{params[:query]}%")
    end

    @pagy, @destinations = pagy(destinations, limit: 20)
  end

  def show
    @pagy, @transfers = pagy(@destination.transfers.order(created_at: :desc), limit: 5)
  end

  def new
    destination_type = Destination.find_type_by_param_name(params[:type])
    if destination_type
      @destination = destination_type.new
    else
      redirect_to destinations_url, alert: "Invalid destination type."
    end
  end

  def create
    @destination = @collection.destinations.build(destination_params)
    if @destination.save
      redirect_to destination_path(@destination), notice: "Destination was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @destination.update(destination_params)
      redirect_to destination_path(@destination), notice: "Destination was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    collection = @destination.collection
    @destination.destroy
    redirect_to collection_path(collection), status: :see_other, notice: "Destination was successfully destroyed."
  end

  def reset
    # TODO: don't allow reset if running an export
    if @destination.ready?
      @destination.reset
      redirect_to destination_path(@destination)
    else
      redirect_to destination_path(@destination), alert: "Preconditions not met. See destination for details."
    end
  end

  def run
    if @destination.ready?
      @destination.run
      redirect_to destination_path(@destination)
    else
      redirect_to destination_path(@destination), alert: "Preconditions not met. See destination for details."
    end
  end

  private

  def destination_params
    params.require(:destination).permit(:type, :name, :url, :identifier, :username, :password, :config)
  end

  def set_collection
    @collection = Collection.find(params[:collection_id])
  end

  def set_destination
    @destination = Destination.find(params[:id])
  end
end
