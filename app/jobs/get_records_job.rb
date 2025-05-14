class GetRecordsJob < ApplicationJob
  limits_concurrency to: 1, key: ->(source) { source }, duration: 1.hour
  queue_as :default

  def perform(source)
    Rails.logger.info "Started import from: #{source.url} #{Time.current}"
    source.broadcast_message("Started import from: #{source.url}")

    records_processed = 0
    last_update_time = Time.current

    source.importer.new(source).import do |record|
      records_processed += 1
      last_update_time = broadcast_message(source, records_processed, last_update_time)

      next unless source.transfer_on_import?

      record.transfer
    end

    source.update(status: "active", message: "Import ran successfully")
  rescue => e
    source.update(status: "failed", message: e.message)
  end
end
