class OaiGetRecordsJob < ApplicationJob
  limits_concurrency to: 5, key: ->(source) { source.url }, duration: 1.hour
  queue_as :default

  def perform(source)
    Rails.logger.info "Started OAI Get Records: #{source.url} #{Time.current}"
    OaiImporter.new(source).import
    Rails.logger.info "Completed OAI Get Records: #{source.url} #{Time.current}"
  end
end
