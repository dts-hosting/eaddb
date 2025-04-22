module Destinations
  class ArcLight < Destination
    validates :identifier, :config, presence: true

    def ok_to_run?
      transfers.any?
    end

    def self.display_name
      "ArcLight"
    end

    def self.version
      Gem::Specification.find_by_name("arclight").version.to_s
    end

    private

    def perform_run(transfer_ids = nil)
      ArcLightSendRecordsJob.perform_later(self, transfer_ids)
    end
  end
end
