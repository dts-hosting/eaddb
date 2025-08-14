class ProcessRecordJob < ApplicationJob
  limits_concurrency to: 20, key: ->(record) { record.collection.source }, duration: 1.minute
  queue_as :default

  def perform(record)
    source = record.collection.source
    importer = source.importer.new(source)
    importer.process(record)
    record.queue_export if record.reload.active? && source.transfer_on_import?
  rescue => e
    record.update(status: "failed", message: e.message)
  end
end
