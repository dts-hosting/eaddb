require "test_helper"

module Destinations
  class ArcLightTest < ActiveSupport::TestCase
    test "is a valid destination subclass" do
      source = sources(:oai)
      collection = Collection.create!(source: source, name: "Test Collection for ArcLight", identifier: "/repositories/4")
      destination = Destinations::ArcLight.new(
        name: "ArcLight Instance",
        url: "https://arclight.example.com",
        collection: collection
      )

      assert destination.valid?
      assert_equal "Destinations::ArcLight", destination.type
    end
  end
end