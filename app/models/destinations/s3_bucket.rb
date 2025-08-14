module Destinations
  class S3Bucket < Destination
    validates :username, :password, presence: true

    def exporter
      Exporters::S3
    end

    def has_url?
      false
    end

    def ok_to_run?
      active? && username.present? && password.present?
    end

    def self.display_name
      "S3"
    end

    def self.version
      # TODO: gem "aws-sdk-s3"
    end
  end
end
