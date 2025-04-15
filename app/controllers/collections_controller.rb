class CollectionsController < ApplicationController
  before_action :set_source_and_collection, only: [:show, :edit, :update, :destroy]

  def show
  end

  def new
    @source = Source.find(params[:source_id])
    @collection = Collection.new(source: @source)
  end

  def create
    @source = Source.find(params[:source_id])
    @collection = @source.collections.build(collection_params)
    if @collection.save
      redirect_to source_collection_path(@source, @collection), notice: "Collection was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @collection.update(collection_params)
      redirect_to source_collection_path(@collection.source, @collection), notice: "Collection was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collection.destroy
    redirect_to source_path(@source), status: :see_other, notice: "Collection was successfully destroyed."
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :identifier, :require_owner_in_record)
  end

  def set_source_and_collection
    @source = Source.find(params[:source_id])
    @collection = @source.collections.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to sources_path, alert: "Collection not found in this source"
  end
end
