require "test_helper"

class Sources::ArchivesSpaceTest < ActiveSupport::TestCase
  include TestConstants::Endpoints
  include ActiveJob::TestHelper

  setup do
    ARCHIVES.values.each do |url|
      stub_request(:head, url).to_return(status: 200)
    end
  end

  test "enqueues correct job" do
    source = Sources::ArchivesSpace.create!(
      name: "Test ArchivesSpace job",
      url: "https://test.archivesspace.org/api"
    )

    assert_enqueued_with(job: ArchivesSpaceGetRecordsJob) do
      source.run
    end
  end
end