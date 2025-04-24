module Destinations
  class ArcLight < Destination
    validates :identifier, :config, presence: true

    def exporter
      ArcLightExporter
    end

    def ok_to_run?
      transfers.any?
    end

    def self.display_name
      "ArcLight"
    end

    def self.version
      Gem::Specification.find_by_name("arclight").version.to_s
    end
  end
end
