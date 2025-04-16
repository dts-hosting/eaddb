class DestinationsController < ApplicationController
  before_action :set_collection, only: [:new, :create]
  before_action :set_destination, only: [:show, :edit, :update, :destroy, :run]

  def show
  end

  def new
    @destination = @collection.destinations.build
  end

  def create
    @destination = @collection.destinations.build(destination_params)
    if @destination.save
      redirect_to destination_path(@destination), notice: "Destination was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @destination.update(destination_params)
      redirect_to destination_path(@destination), notice: "Destination was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    collection = @destination.collection
    @destination.destroy
    redirect_to collection_path(collection), notice: "Destination was successfully destroyed."
  end

  def run
    if @destination.ok_to_run?
      @destination.run
      redirect_to destination_path(@destination), notice: "Job has been queued for this destination."
    else
      redirect_to destination_path(@destination), alert: "Could not queue job for this destination."
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
