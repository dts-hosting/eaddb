class SendRecordsJob < ApplicationJob
  limits_concurrency to: 1, key: ->(destination) { destination }, duration: 1.hour
  queue_as :default

  def perform(destination)
    destination.update(message: "Export started", started_at: Time.current, completed_at: nil)

    records_processed = 0

    # TODO: more efficiently and scope
    destination.records.where(status: "active").find_each do |record|
      next unless record.transferable?

      Transfer.create(action: "export", record: record, destination: destination)
      records_processed += 1
    end

    destination.update(
      status: "active",
      message: I18n.t("jobs.export_queued", count: records_processed),
      completed_at: Time.current
    )
  rescue => e
    destination.update(status: "failed", message: e.message)
  end
end
