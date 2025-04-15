require "test_helper"

module Sources
  class ArchivesSpaceTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test "validates url ends with /api for ArchivesSpace" do
      valid_source = Sources::ArchivesSpace.new(
        name: "Test ArchivesSpace source",
        url: "https://test.archivesspace.org/staff/api"
      )
      assert valid_source.valid?

      invalid_source = Sources::ArchivesSpace.new(
        name: "Test ArchivesSpace source",
        url: "https://test.archivesspace.org/staff"
      )
      assert_not invalid_source.valid?
      assert_includes invalid_source.errors[:url], "must end with '/api'"
    end

    test "enqueues correct job" do
      source = Sources::ArchivesSpace.create!(
        name: "Test ArchivesSpace source",
        url: "https://test.archivesspace.org/api",
        username: "admin",
        password: "<PASSWORD>"
      )
      create_collection(source: source)

      assert_enqueued_with(job: ArchivesSpaceGetRecordsJob) do
        source.run
      end
    end
  end
end
