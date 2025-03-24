module Destinations
  class ArcLight < Destination
    validates :identifier, presence: true
    validates :config, presence: true

    def run
      ArcLightSendRecordsJob.perform_later(self)
    end
  end
end
