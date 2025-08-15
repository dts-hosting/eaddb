class CollectionsController < ApplicationController
  before_action :set_collection, only: [:show, :edit, :update, :destroy]
  before_action :set_source, only: [:new, :create]

  def show
    @pagy, @destinations = pagy(@collection.destinations, limit: 5)
  end

  def new
    @collection = @source.collections.build
  end

  def create
    @collection = @source.collections.build(collection_params)
    if @collection.save
      redirect_to collection_path(@collection), notice: "Collection was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @collection.update(collection_params)
      redirect_to collection_path(@collection), notice: "Collection was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    source = @collection.source
    @collection.destroy
    redirect_to source_path(source), status: :see_other, notice: "Collection was successfully destroyed."
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :identifier, :require_owner_in_record)
  end

  def set_collection
    @collection = Collection.find(params[:id])
    @source = @collection.source
  end

  def set_source
    @source = Source.find(params[:source_id])
  end
end
