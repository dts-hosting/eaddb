require "test_helper"

class DestinationResetIntegrationTest < ActionDispatch::IntegrationTest
  include FactoryHelpers

  setup do
    sign_in(users(:admin))
    @collection = create_collection
    @destination = create_destination(
      type: :arc_light,
      attributes: {
        collection: @collection,
        url: "http://example.com/solr"
      }
    )

    @record1 = create_record(collection: @collection)
    @record2 = create_record(collection: @collection)
  end

  # TODO: reimplement
  test "reset destination through controller endpoint" do
    Exporters::ArcLight.any_instance.stubs(:reset).returns(true)
  end
end
