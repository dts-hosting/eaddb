require "test_helper"

module Destinations
  class ArcLightTest < ActiveSupport::TestCase
    test "is a valid destination subclass" do
      collection = create_collection
      destination = create_destination(
        type: :arc_light,
        attributes: {collection: collection}
      )

      assert destination.valid?
      assert_equal "Destinations::ArcLight", destination.type
    end
  end
end
