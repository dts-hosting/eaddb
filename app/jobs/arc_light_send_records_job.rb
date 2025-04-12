class ArcLightSendRecordsJob < ApplicationJob
  limits_concurrency to: 5, key: ->(destination, transfer_ids) { destination.url }, duration: 1.minute
  queue_as :default

  def perform(destination, transfer_ids = nil)
    Rails.logger.info "Started ArcLight Send Records: #{destination.url} #{Time.current}"
    ArcLightExporter.new(destination).export(transfer_ids)
    Rails.logger.info "Completed ArcLight Send Records: #{destination.url} #{Time.current}"
  end
end
