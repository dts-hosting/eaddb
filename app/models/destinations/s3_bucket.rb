module Destinations
  class S3Bucket < Destination
    def run(transfer_ids = nil)
      S3SendRecordsJob.perform_later(self, transfer_ids)
    end

    def self.version
      # TODO: gem "aws-sdk-s3"
    end
  end
end
