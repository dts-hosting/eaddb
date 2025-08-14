class GetRecordsJob < ApplicationJob
  limits_concurrency to: 1, key: ->(source) { source }, duration: 1.hour
  queue_as :default

  def perform(source)
    source.update(message: "Import started", started_at: Time.current, completed_at: nil)

    records_processed = 0
    last_update_time = Time.current

    source.importer.new(source).import do |_|
      records_processed += 1
      last_update_time = report_progress(source, records_processed, last_update_time)
    end

    source.update(
      status: "active",
      message: I18n.t("jobs.import_completed", count: records_processed),
      completed_at: Time.current
    )
  rescue => e
    source.update(status: "failed", message: e.message)
  end
end
