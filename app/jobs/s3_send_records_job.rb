class S3SendRecordsJob < ApplicationJob
  limits_concurrency to: 5, key: ->(destination) { destination.url }, duration: 1.hour
  queue_as :default

  def perform(destination, transfer_ids = nil)
    Rails.logger.info "Started S3 Send Records: #{destination.url} #{Time.current}"
    # S3Exporter.new(destination).export(transfer_ids)
    sleep 1 # placeholder pretend we did something ...
    Rails.logger.info "Completed S3 Send Records: #{destination.url} #{Time.current}"
  end
end
