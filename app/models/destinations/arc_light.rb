module Destinations
  class ArcLight < Destination
    validates :identifier, presence: true

    def run
      ArcLightSendRecordsJob.perform_later(self)
    end
  end
end
