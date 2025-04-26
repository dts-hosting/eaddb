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

    @transfer1 = Transfer.find_by(record: @record1, destination: @destination)
    @transfer1.update(status: "succeeded")

    @transfer2 = Transfer.find_by(record: @record2, destination: @destination)
    @transfer2.update(status: "failed", message: "Error message")
  end

  test "reset destination through controller endpoint" do
    ArcLightExporter.any_instance.stubs(:reset).returns(true)

    assert_equal "succeeded", @transfer1.status
    assert_equal "failed", @transfer2.status

    post reset_destination_path(@destination)
    assert_redirected_to destination_path(@destination)

    @transfer1.reload
    @transfer2.reload

    assert_equal "pending", @transfer1.status
    assert_equal "pending", @transfer2.status

    assert_nil @transfer1.message
    assert_nil @transfer2.message
  end
end
