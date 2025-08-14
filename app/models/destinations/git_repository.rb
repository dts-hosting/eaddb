module Destinations
  class GitRepository < Destination
    validates :url, presence: true, format: {with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL"}
    attribute :username, :string, default: "x-access-token"
    validates :username, :password, presence: true

    def exporter
      Exporters::GitRepository
    end

    def has_url?
      true
    end

    def ok_to_run?
      active? && username.present? && password.present?
    end

    def self.display_name
      "Git Repository"
    end

    def self.version
      # TODO: gem "git"
    end
  end
end
