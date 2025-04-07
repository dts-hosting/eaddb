class GetRecordsFromSourcesJob < ApplicationJob
  queue_as :default

  def perform
    Source.find_each { |source| source.run }
  end
end
