class OaiGetRecordsJob < ApplicationJob
  limits_concurrency to: 1, key: ->(source) { source.url }, duration: 2.hours
  queue_as :default

  def perform(source)
    Rails.logger.info "Started OAI Get Records: #{source.url} #{Time.current}"
    OaiImporter.new(source).import do |record|
      # TODO: next unless source.transfer_on_import?

      record.transfer
    end
    Rails.logger.info "Completed OAI Get Records: #{source.url} #{Time.current}"
  end
end
