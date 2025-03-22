class OaiGetRecordsJob < ApplicationJob
  queue_as :default

  def perform(source)
    OaiImporter.new(source).import
  end
end
