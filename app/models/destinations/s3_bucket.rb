module Destinations
  class S3Bucket < Destination
    validates :username, :password, presence: true

    def exporter
      Exporters::S3
    end

    def ok_to_run?
      username.present? && password.present? && transfers.any?
    end

    def self.display_name
      "S3"
    end

    def self.version
      # TODO: gem "aws-sdk-s3"
    end
  end
end
