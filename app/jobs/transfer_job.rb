class TransferJob < ApplicationJob
  limits_concurrency to: 20, key: ->(transfer) { transfer.destination }, duration: 5.minutes
  queue_as :default

  def perform(transfer)
    exporter = transfer.destination.exporter.new(transfer)
    exporter.process
  rescue => e
    transfer.failed!(e.message)
  end
end
