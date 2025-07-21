class SendRecordsJob < ApplicationJob
  limits_concurrency to: 1, key: ->(destination, _) { destination }, duration: 1.hour
  queue_as :default

  def perform(destination, transfer_ids = nil)
    destination.update(message: "Export started", started_at: Time.current, completed_at: nil)

    records_processed = 0
    last_update_time = Time.current

    destination.exporter.new(destination).export(transfer_ids) do |_|
      records_processed += 1
      last_update_time = report_progress(destination, records_processed, last_update_time)
    end

    destination.update(
      status: "active",
      message: I18n.t("jobs.export_completed", count: records_processed),
      completed_at: Time.current
    )
  rescue => e
    destination.update(status: "failed", message: e.message)
  end
end
