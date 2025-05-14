class SendRecordsJob < ApplicationJob
  limits_concurrency to: 1, key: ->(destination, _) { destination }, duration: 1.hour
  queue_as :default

  def perform(destination, transfer_ids = nil)
    Rails.logger.info "Started sending records to: #{destination.url} #{Time.current}"
    destination.broadcast_message("Started sending records to: #{destination.url}")

    records_processed = 0
    last_update_time = Time.current

    destination.exporter.new(destination).export(transfer_ids) do |_|
      records_processed += 1
      last_update_time = broadcast_message(destination, records_processed, last_update_time)
    end

    destination.update(status: "active", message: "Export ran successfully")
  rescue => e
    destination.update(status: "failed", message: e.message)
  end
end
