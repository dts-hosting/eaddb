class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  def report_progress(record, records_processed, last_update_time)
    current_time = Time.current
    if current_time - last_update_time > 5.seconds
      record.update(message: I18n.t("jobs.records_processed", count: records_processed))
      return current_time
    end
    last_update_time
  end
end
