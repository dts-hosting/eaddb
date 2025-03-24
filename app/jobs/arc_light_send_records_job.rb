class ArcLightSendRecordsJob < ApplicationJob
  queue_as :default

  def perform(destination)
    Rails.logger.info "Started ArcLight Send Records: #{destination.url} #{Time.current}"
    ArcLightExporter.new(destination).export
    Rails.logger.info "Completed ArcLight Send Records: #{destination.url} #{Time.current}"
  end
end
