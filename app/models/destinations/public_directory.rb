module Destinations
  class PublicDirectory < Destination
    validates :identifier, presence: true

    def exporter
      Exporters::PublicDirectory
    end

    def has_url?
      false
    end

    def ready?
      active?
    end

    def self.display_name
      "Public Directory"
    end

    def self.version
      "1.0"
    end
  end
end
