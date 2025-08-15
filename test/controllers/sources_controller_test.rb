require "test_helper"

class SourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:admin))
    @source = create_source
  end

  test "should get index" do
    get sources_url
    assert_response :success
    assert_select "h2", "Sources"
  end

  test "should get new" do
    get new_sources_path(type: "oai")
    assert_response :success
    assert_select "h2", "New Source"
  end

  test "should create source" do
    assert_difference("Source.count") do
      post sources_url, params: {
        source: {
          name: "New Test Source",
          url: "https://example.com/oai",
          type: "Sources::Oai"
        }
      }
    end

    assert_redirected_to source_url(Source.last)
    assert_equal "Source was successfully created.", flash[:notice]
  end

  test "should not create source with invalid params" do
    assert_no_difference("Source.count") do
      post sources_url, params: {
        source: {
          type: "Sources::Oai",
          name: "",
          url: "https://example.com/oai"
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "should show source" do
    get source_url(@source)
    assert_response :success
    assert_select "h2", @source.name
  end

  test "should get edit" do
    get edit_source_url(@source)
    assert_response :success
    assert_select "h2", "Edit Source"
  end

  test "should update source" do
    patch source_url(@source), params: {
      source: {
        name: "Updated Source Name",
        url: @source.url
      }
    }
    assert_redirected_to source_url(@source)
    assert_equal "Source was successfully updated.", flash[:notice]
    @source.reload
    assert_equal "Updated Source Name", @source.name
  end

  test "should not update source with invalid params" do
    patch source_url(@source), params: {
      source: {
        name: "",
        url: @source.url
      }
    }
    assert_response :unprocessable_content
  end

  test "should destroy source" do
    assert_difference("Source.count", -1) do
      delete source_url(@source)
    end

    assert_redirected_to sources_url
    assert_equal "Source was successfully destroyed.", flash[:notice]
  end

  test "should handle failure when destroying source" do
    create_collection(source: @source)

    assert_no_difference("Source.count") do
      delete source_url(@source)
    end

    assert_redirected_to sources_url
    assert_equal "Source could not be destroyed: Cannot delete source while collections exist.", flash[:alert]
  end

  test "pagination works on show page" do
    15.times do
      create_collection(source: @source)
    end

    get source_url(@source)
    assert_response :success
    assert_select "nav.pagination"
  end

  test "should redirect with alert when no collections exist" do
    @source.collections.destroy_all
    post run_source_path(@source)

    assert_redirected_to source_path(@source)
    assert_equal "Preconditions not met. See source for details.", flash[:alert]
  end

  test "should start job when collections exist" do
    create_collection(source: @source)

    assert_enqueued_with(job: GetRecordsJob) do
      post run_source_path(@source)
    end

    assert_redirected_to source_path(@source)
  end
end
