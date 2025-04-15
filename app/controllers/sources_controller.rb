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
    @source = Source.new
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
    @source.destroy
    redirect_to sources_url, status: :see_other, notice: "Source was successfully destroyed."
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
    # TODO: username, password if type supports it
    params.require(:source).permit(:type, :name, :url)
  end
end
