require "test_helper"

class DestinationTest < ActiveSupport::TestCase
  setup do
    source = sources(:oai)
    @collection = Collection.create!(source: source, name: "Test Collection for Destination", identifier: "/repositories/4")
    @ead_xml = fixture_file_upload(
      Rails.root.join("test/fixtures/files/sample.xml"),
      "application/xml"
    )
    @record = Record.create!(
      collection: @collection,
      identifier: "unique-id-123",
      creation_date: Date.current,
      modification_date: Date.current,
      ead_xml: @ead_xml
    )
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
    Destinations::ArcLight.create!(name: "Shared Name", url: "https://example1.com", collection: @collection)

    duplicate = Destinations::ArcLight.new(name: "Shared Name", url: "https://example2.com", collection: @collection)
    assert_not duplicate.valid?

    different_type = Destinations::S3Bucket.new(name: "Shared Name", url: "https://example3.com", collection: @collection)
    assert different_type.valid?
  end

  test "encrypts username and password" do
    destination = Destinations::ArcLight.create!(
      name: "With Credentials",
      url: "https://example.com",
      username: "user123",
      password: "secret123",
      collection: @collection
    )

    destination.reload

    assert_not_equal "user123", destination.attributes_before_type_cast["username"]
    assert_not_equal "secret123", destination.attributes_before_type_cast["password"]

    assert_equal "user123", destination.username
    assert_equal "secret123", destination.password
  end

  test "creates transfers for all collection records after creation" do
    record2 = Record.create!(
      collection: @collection,
      identifier: "unique-id-456",
      creation_date: Date.current,
      modification_date: Date.current,
      ead_xml: @ead_xml
    )
    record3 = Record.create!(
      collection: @collection,
      identifier: "unique-id-789",
      creation_date: Date.current,
      modification_date: Date.current,
      ead_xml: @ead_xml
    )

    destination = Destinations::ArcLight.create!(
      name: "New Destination",
      url: "https://example.com",
      collection: @collection
    )

    assert_equal @collection.records.count, destination.transfers.count
    assert destination.transfers.all? { |t| t.pending? }

    [@record, record2, record3].each do |record|
      assert Transfer.exists?(record: record, destination: destination)
    end
  end
end