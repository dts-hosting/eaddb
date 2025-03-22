require "test_helper"

module Destinations
  class S3BucketTest < ActiveSupport::TestCase
    test "is a valid destination subclass" do
      source = sources(:oai)
      collection = Collection.create!(source: source, name: "Test Collection for S3", identifier: "/repositories/4")
      destination = Destinations::S3Bucket.new(
        name: "S3 Instance", 
        url: "s3://my-bucket", 
        collection: collection
      )

      assert destination.valid?
      assert_equal "Destinations::S3Bucket", destination.type
    end
  end
end