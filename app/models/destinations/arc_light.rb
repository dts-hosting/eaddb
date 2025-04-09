module Destinations
  class ArcLight < Destination
    validates :identifier, presence: true
    validates :config, presence: true

    def run(transfer_ids = nil)
      ArcLightSendRecordsJob.perform_later(self, transfer_ids)
    end

    def self.version
      Gem::Specification.find_by_name("arclight").version.to_s
    end
  end
end
