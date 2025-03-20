require "test_helper"

class Sources::ArchivesSpaceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    stub_request(:head, "https://test.archivesspace.org/api").to_return(status: 200)
  end

  test "enqueues correct job" do
    source = Sources::ArchivesSpace.create!(
      name: "Test Archives",
      url: "https://test.archivesspace.org/api"
    )

    assert_enqueued_with(job: ArchivesSpaceGetRecordsJob) do
      source.run
    end
  end
end