class OaiGetRecordsJob < ApplicationJob
  queue_as :default

  def perform(source)
    Rails.logger.info "Started OAI Get Records: #{source.url} #{Time.current}"
    OaiImporter.new(source).import
    Rails.logger.info "Completed OAI Get Records: #{source.url} #{Time.current}"
  end
end
