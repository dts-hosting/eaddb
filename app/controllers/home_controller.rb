class HomeController < ApplicationController
  # TODO: offload to a background job if complexity increases
  before_action :set_stats, :set_sources_with_collections, :set_collections_with_records
  def index
  end

  private

  def set_collections_with_records
    @collections_with_records = Rails.cache.fetch("collections_with_records", expires_in: 1.hour) do
      Collection.left_joins(:records)
        .select("collections.id, collections.name, COUNT(records.id) as records_count")
        .group("collections.id")
        .order("records_count DESC, collections.name")
        .limit(5)
    end
  end

  def set_sources_with_collections
    @sources_with_collections = Rails.cache.fetch("sources_with_collections", expires_in: 1.hour) do
      Source.left_joins(:collections)
        .select("sources.id, sources.name, COUNT(collections.id) as collections_count")
        .group("sources.id")
        .order("collections_count DESC, sources.name")
        .limit(5)
    end
  end

  def set_stats
    @stats = Rails.cache.fetch("stats", expires_in: 1.hour) do
      {
        sources_count: Source.count,
        collections_count: Collection.count,
        records_count: Record.count,
        destinations_count: Destination.count
      }
    end
  end
end
