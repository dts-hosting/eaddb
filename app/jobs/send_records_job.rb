class SendRecordsJob < ApplicationJob
  limits_concurrency to: 1, key: ->(destination, _) { destination.url }, duration: 1.hour
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

    destination.broadcast_message("Completed sending #{records_processed} records to: #{destination.url}")
    sleep 3
    destination.touch # now refresh the page

    Rails.logger.info "Completed sending records to: #{destination.url} #{Time.current}"
  end
end
