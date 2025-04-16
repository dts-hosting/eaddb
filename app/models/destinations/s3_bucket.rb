module Destinations
  class S3Bucket < Destination
    def ok_to_run?
      username.present? && password.present? && transfers.any?
    end

    def run(transfer_ids = nil)
      return unless ok_to_run?

      S3SendRecordsJob.perform_later(self, transfer_ids)
    end

    def self.display_name
      "S3"
    end

    def self.version
      # TODO: gem "aws-sdk-s3"
    end
  end
end
