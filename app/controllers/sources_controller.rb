class SourcesController < ApplicationController
  before_action :set_source, only: %i[show edit update destroy run]

  def index
    sources = Source.order(:name)

    if params[:query].present?
      sources = sources.where("name LIKE ?", "%#{params[:query]}%")
    end

    @pagy, @sources = pagy(sources, items: 100)
  end

  def show
    @pagy, @collections = pagy(@source.collections.order(:name), limit: 10)
  end

  def new
    source_type = Source.descendants_by_display_name[params[:type]]
    if source_type
      @source = source_type.constantize.new
    else
      redirect_to sources_url, alert: "Invalid source type."
    end
  end

  def create
    @source = Source.new(source_params)
    if @source.save
      redirect_to source_path(@source), notice: "Source was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @source.update(source_params)
      redirect_to source_path(@source), notice: "Source was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @source.destroy
      redirect_to sources_url, status: :see_other, notice: "Source was successfully destroyed."
    else
      redirect_to sources_url, alert: "Source could not be destroyed: #{@source.errors.full_messages.join(", ")}"
    end
  end

  def run
    if @source.ok_to_run?
      @source.run
      redirect_to source_path(@source)
    else
      redirect_to source_path(@source), alert: "Preconditions not met. See source for details."
    end
  end

  private

  def set_source
    @source = Source.find(params[:id])
  end

  def source_params
    params.require(:source).permit(:type, :name, :url, :transfer_on_import, :username, :password)
  end
end
