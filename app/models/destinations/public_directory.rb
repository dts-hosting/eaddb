module Destinations
  class PublicDirectory < Destination
    validates :identifier, presence: true

    def exporter
      Exporters::PublicDirectory
    end

    def has_url?
      false
    end

    def ok_to_run?
      transfers.any?
    end

    def self.display_name
      "Public Directory"
    end

    def self.version
      "1.0"
    end
  end
end
