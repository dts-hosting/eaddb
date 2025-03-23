require "test_helper"

module Destinations
  class ArcLightTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test "is a valid destination subclass" do
      destination = create_destination(
        type: :arc_light,
        attributes: {collection: create_collection}
      )

      assert destination.valid?
      assert_equal "Destinations::ArcLight", destination.type
    end

    test "requires an identifier" do
      destination = create_destination(
        type: :arc_light,
        attributes: {collection: create_collection}
      )
      destination.identifier = nil
      assert_not destination.valid?
      assert_includes destination.errors.messages[:identifier], "can't be blank"
    end

    test "enqueues correct job" do
      destination = create_destination(
        type: :arc_light,
        attributes: {collection: create_collection}
      )

      assert_enqueued_with(job: ArcLightSendRecordsJob) do
        destination.run
      end
    end
  end
end
