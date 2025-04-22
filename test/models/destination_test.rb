require "test_helper"

class DestinationTest < ActiveSupport::TestCase
  setup do
    @collection = create_collection
    @record = create_record(collection: @collection)
  end

  test "requires a name" do
    destination = Destination.new(url: "https://example.com", collection: @collection)
    assert_not destination.valid?
    assert_includes destination.errors[:name], "can't be blank"
  end

  test "requires a URL" do
    destination = Destination.new(name: "Test Destination", collection: @collection)
    assert_not destination.valid?
    assert_includes destination.errors[:url], "can't be blank"
  end

  test "name must be unique per type" do
    create_destination(
      type: :arc_light,
      attributes: {name: "Shared Name", collection: @collection, url: "https://example.com"}
    )

    duplicate = Destinations::ArcLight.new(name: "Shared Name", url: "https://example.com", collection: @collection)
    assert_not duplicate.valid?

    different_type = Destinations::S3Bucket.new(
      name: "Shared Name",
      url: "https://example.com",
      collection: @collection,
      username: "user",
      password: "password"
    )
    assert different_type.valid?
  end

  test "encrypts username and password" do
    destination = create_destination(
      attributes: {
        username: "user123",
        password: "secret123",
        collection: @collection
      }
    )

    destination.reload

    assert_not_equal "user123", destination.attributes_before_type_cast["username"]
    assert_not_equal "secret123", destination.attributes_before_type_cast["password"]

    assert_equal "user123", destination.username
    assert_equal "secret123", destination.password
  end

  test "creates transfers for all collection records after creation" do
    record2 = create_record(collection: @collection)
    record3 = create_record(collection: @collection)

    destination = create_destination(attributes: {collection: @collection})

    assert_equal @collection.records.count, destination.transfers.count
    assert destination.transfers.all?(&:pending?)

    [@record, record2, record3].each do |record|
      assert Transfer.exists?(record: record, destination: destination)
    end
  end
end
