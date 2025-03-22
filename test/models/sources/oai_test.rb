require "test_helper"

module Sources
  class OaiTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test "validates url ends with /oai for OAI" do
      valid_source = Sources::Oai.new(
        name: "Test OAI source",
        url: "https://test.archivesspace.org/oai"
      )
      assert valid_source.valid?

      invalid_source = Sources::Oai.new(
        name: "Test OAI",
        url: "https://test.archivesspace.org/api"
      )
      assert_not invalid_source.valid?
      assert_includes invalid_source.errors[:url], "must end with '/oai'"
    end

    test "enqueues correct job" do
      source = Sources::Oai.create!(
        name: "Test OAI source",
        url: "https://test.archivesspace.org/oai"
      )

      assert_enqueued_with(job: OaiGetRecordsJob) do
        source.run
      end
    end
  end
end
