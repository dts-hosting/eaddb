require "test_helper"

class CollectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:admin))
    @source = create_source
    @collection = create_collection(source: @source)
    @valid_attributes = {
      name: "New Collection",
      identifier: "/repositories/#{rand(1..1000)}",
      require_owner_in_record: false,
      source_id: @source.id
    }
    @invalid_attributes = {
      name: nil,
      identifier: "invalid-collection",
      source_id: @source.id
    }
  end

  test "should get show" do
    get collection_url(@collection)
    assert_response :success
    assert_select "h2", text: /#{@collection.name}/i
  end

  test "should get new" do
    get new_source_collection_url(@source)
    assert_response :success
    assert_select "form[action=?]", source_collections_path(@source)
  end

  test "should create collection with valid attributes" do
    assert_difference("Collection.count") do
      post source_collections_url(@source), params: {collection: @valid_attributes}
    end

    new_collection = Collection.last
    assert_redirected_to collection_url(new_collection)
    assert_equal "Collection was successfully created.", flash[:notice]
  end

  test "should not create collection with invalid attributes" do
    assert_no_difference("Collection.count") do
      post source_collections_url(@source), params: {collection: @invalid_attributes}
    end

    assert_response :unprocessable_content
    assert_select "div.alert-danger", /prohibited this collection from being saved/i
  end

  test "should get edit" do
    get edit_collection_url(@source, @collection)
    assert_response :success
    assert_select "form[action=?]", collection_path(@collection)
    assert_select "input[name='collection[name]'][value=?]", @collection.name
  end

  test "should update collection with valid attributes" do
    new_name = "Updated Collection Name"

    patch collection_url(@collection), params: {collection: {name: new_name}}

    assert_redirected_to collection_url(@collection)
    @collection.reload
    assert_equal new_name, @collection.name
    assert_equal "Collection was successfully updated.", flash[:notice]
  end

  test "should not update collection with invalid attributes" do
    patch collection_url(@collection), params: {collection: @invalid_attributes}

    assert_response :unprocessable_content
    assert_select "div.alert-danger", /prohibited this collection from being saved/i
  end

  test "should destroy collection" do
    assert_difference("Collection.count", -1) do
      delete collection_url(@collection)
    end

    assert_redirected_to source_url(@source)
    assert_equal "Collection was successfully destroyed.", flash[:notice]
    assert_response :see_other
  end
end
