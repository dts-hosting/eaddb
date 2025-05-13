module Destinations
  class ArcLight < Destination
    validates :identifier, :config, presence: true
    # TODO: validates identifier in config

    def exporter
      Exporters::ArcLight
    end

    def ok_to_run?
      transfers.any?
    end

    # TODO: cache
    def repositories
      YAML.safe_load(config.download)
    end

    def repository
      repositories[identifier]
    end

    def repository_name
      repository["name"] if repository
    end

    def self.display_name
      "ArcLight"
    end

    def self.version
      Gem::Specification.find_by_name("arclight").version.to_s
    end
  end
end
