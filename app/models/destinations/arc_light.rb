module Destinations
  class ArcLight < Destination
    validates :url, presence: true, format: {with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL"}
    validates :identifier, :config, presence: true

    after_commit :validate_identifier_in_config

    def exporter
      Exporters::ArcLight
    end

    def has_url?
      true
    end

    def ok_to_run?
      active? && identifier.present? && config.attached?
    end

    def repositories
      Rails.cache.fetch("repositories_cfg_#{id}", expires_in: 1.hour) do
        YAML.safe_load(config.download)
      end
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

    private

    def validate_identifier_in_config
      return unless active? && config.attached?

      unless repositories.key?(identifier)
        update(status: "failed", message: "identifier '#{identifier}' not found in configuration")
      end
    rescue => e
      update(status: "failed", message: e.message)
    end
  end
end
