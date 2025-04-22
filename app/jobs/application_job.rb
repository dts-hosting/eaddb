class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  def broadcast_message(record, records_processed, last_update_time)
    current_time = Time.current
    if current_time - last_update_time > 5.seconds
      message = "Processed #{records_processed} records"
      record.broadcast_message(message)
      return current_time
    end
    last_update_time
  end
end
