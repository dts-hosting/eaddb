require "test_helper"

class Sources::OaiTest < ActiveSupport::TestCase
  include TestConstants::Endpoints
  include ActiveJob::TestHelper

  setup do
    ARCHIVES.values.each do |url|
      stub_request(:head, url).to_return(status: 200)
    end
  end

  test "enqueues correct job" do
    source = Sources::Oai.create!(
      name: "Test OAI job",
      url: "https://test.archivesspace.org/oai"
    )

    assert_enqueued_with(job: OaiGetRecordsJob) do
      source.run
    end
  end
end