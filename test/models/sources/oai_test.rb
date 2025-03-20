require "test_helper"

class Sources::OaiTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    stub_request(:head, "https://test.archivesspace.org/oai").to_return(status: 200)
  end

  test "enqueues correct job" do
    source = Sources::Oai.create!(
      name: "Test OAI",
      url: "https://test.archivesspace.org/oai"
    )

    assert_enqueued_with(job: OaiGetRecordsJob) do
      source.run
    end
  end
end