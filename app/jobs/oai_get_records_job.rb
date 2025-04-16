class OaiGetRecordsJob < ApplicationJob
  limits_concurrency to: 1, key: ->(source) { source.url }, duration: 2.hours
  queue_as :default

  def perform(source)
    Rails.logger.info "Started import from: #{source.url} #{Time.current}"
    source.broadcast_import_progress("Started import from #{source.url}")

    records_processed = 0
    last_update_time = Time.current

    OaiImporter.new(source).import do |record|
      records_processed += 1
      last_update_time = broadcast_import_progress(source, records_processed, last_update_time)

      next unless source.transfer_on_import?

      record.transfer
    end

    source.broadcast_import_progress("Completed import of #{records_processed} records from #{source.url}")
    sleep 3
    source.touch # now refresh the page

    Rails.logger.info "Completed OAI Get Records: #{source.url} #{Time.current}"
  end
end
