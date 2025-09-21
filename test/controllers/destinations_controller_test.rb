require "test_helper"

class DestinationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:admin))
    @collection = create_collection
    create_record(collection: @collection)
    @destination = create_destination(type: :arc_light, attributes: {collection: @collection})
  end

  test "should get show" do
    get destination_url(@destination)
    assert_response :success
  end

  test "should get new" do
    get new_collection_destinations_path(@collection, type: "arclight")
    assert_response :success
  end

  test "should create destination" do
    assert_difference("Destination.count") do
      post collection_destinations_url(@collection), params: {
        destination: {
          type: "Destinations::ArcLight",
          name: "New Destination",
          url: "https://localhost:8983/solr/arclight",
          identifier: "test-identifier",
          config: fixture_file_upload(
            Rails.root.join("test/fixtures/files/repositories.yml"),
            "application/xml"
          )
        }
      }
    end

    assert_redirected_to destination_url(Destination.last)
    assert_equal "Destination was successfully created.", flash[:notice]
  end

  test "should not create destination with invalid attributes" do
    assert_no_difference("Destination.count") do
      post collection_destinations_url(@collection), params: {
        destination: {
          type: "Destinations::ArcLight",
          name: "",
          url: "https://example.com"
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "should get edit" do
    get edit_destination_url(@destination)
    assert_response :success
  end

  test "should update destination" do
    patch destination_url(@destination), params: {
      destination: {
        name: "Updated Destination",
        url: "https://updated-example.com"
      }
    }

    assert_redirected_to destination_url(@destination)
    assert_equal "Destination was successfully updated.", flash[:notice]
    @destination.reload
    assert_equal "Updated Destination", @destination.name
    assert_equal "https://updated-example.com", @destination.url
  end

  test "should not update destination with invalid attributes" do
    original_name = @destination.name

    patch destination_url(@destination), params: {
      destination: {
        name: "",
        url: @destination.url
      }
    }

    assert_response :unprocessable_content
    @destination.reload
    assert_equal original_name, @destination.name
  end

  test "should destroy destination" do
    collection = @destination.collection

    assert_difference("Destination.count", -1) do
      delete destination_url(@destination)
    end

    assert_redirected_to collection_url(collection)
    assert_equal "Destination was successfully destroyed.", flash[:notice]
  end

  test "should redirect with alert when preconditions are not met" do
    Destinations::ArcLight.any_instance.stubs(:ready?).returns(false)
    post run_destination_path(@destination)

    assert_redirected_to destination_path(@destination)
    assert_equal "Preconditions not met. See destination for details.", flash[:alert]
  end

  test "should start job when preconditions are met" do
    assert_enqueued_with(job: SendRecordsJob) do
      post run_destination_path(@destination)
    end

    assert_redirected_to destination_path(@destination)
  end
end
