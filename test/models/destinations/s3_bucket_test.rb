require "test_helper"

module Destinations
  class S3BucketTest < ActiveSupport::TestCase
    test "is a valid destination subclass" do
      collection = create_collection
      destination = create_destination(
        type: :s3_bucket,
        attributes: {collection: collection, username: "user", password: "password"}
      )

      assert destination.valid?
      assert_equal "Destinations::S3Bucket", destination.type
    end
  end
end
