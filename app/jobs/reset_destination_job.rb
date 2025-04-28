class ResetDestinationJob < ApplicationJob
  limits_concurrency to: 1, key: ->(destination) { destination.url }, duration: 1.hour
  queue_as :default

  def perform(destination)
    Rails.logger.info "Reset started for: #{destination.url} #{Time.current}"
    destination.broadcast_message("Reset started for: #{destination.url}")
    destination.exporter.new(destination).reset
    destination.update(status: "active", message: "Reset ran successfully")
  rescue => e
    destination.update(status: "failed", message: e.message)
  end
end
