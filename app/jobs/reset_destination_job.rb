class ResetDestinationJob < ApplicationJob
  limits_concurrency to: 1, key: ->(destination) { destination }, duration: 1.hour
  queue_as :default

  def perform(destination)
    destination.update(message: "Reset started", started_at: Time.current, completed_at: nil)
    destination.exporter.reset(destination)
    destination.update(status: "active", message: "Reset completed", completed_at: Time.current)
  rescue => e
    destination.update(status: "failed", message: e.message)
  end
end
