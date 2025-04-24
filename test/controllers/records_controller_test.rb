require "test_helper"

class RecordsControllerTest < ActionDispatch::IntegrationTest
  include FactoryHelpers

  setup do
    sign_in(users(:admin))
    @record = create_record
    @collection = @record.collection
    5.times do |i|
      create_record(
        collection: @collection,
        ead_identifier: "test-ead-#{i}"
      )
    end

    @other_collection = create_collection(name: "Other Test Collection")
    @other_record = create_record(
      collection: @other_collection,
      ead_identifier: "other-test-ead"
    )
  end

  test "should get index with no records when no filters" do
    get records_url
    assert_response :success
    assert_select "div.card-body", 0
  end

  test "should filter records by query" do
    get records_url(query: "test-ead-1")
    assert_response :success

    assert_select "div.card-body", 1
  end

  test "should filter records by collection name" do
    get records_url(collection: @collection.name)
    assert_response :success

    assert_select "div.card-body", 6
  end

  test "should filter by both query and collection" do
    get records_url(query: "test-ead", collection: @collection.name)
    assert_response :success

    assert_select "div.card-body", 5
  end

  test "should not find records from other collections when filtering by collection" do
    get records_url(collection: @collection.name)
    assert_response :success

    assert_select "div##{dom_id(@other_record)}", 0
  end

  test "should get show page for record" do
    get record_url(@record)
    assert_response :success

    assert_select "h2", @record.ead_identifier
    assert_select "h5", "Transfers"
  end

  test "should handle non-existent record gracefully" do
    non_existent_id = Record.maximum(:id).to_i + 1000
    assert_raises(ActiveRecord::RecordNotFound) do
      Record.find(non_existent_id)
    end

    get record_url(non_existent_id)
    assert_response :not_found
  end
end
