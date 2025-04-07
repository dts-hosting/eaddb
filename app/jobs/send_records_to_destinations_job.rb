class SendRecordsToDestinationsJob < ApplicationJob
  queue_as :default

  def perform
    Destination.find_each { |destination| destination.run }
  end
end