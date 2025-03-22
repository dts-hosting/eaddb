require "test_helper"

class TransferTest < ActiveSupport::TestCase
  setup do
    source = sources(:oai)
    @collection = Collection.create!(source: source, name: "Test Collection for Transfer", identifier: "/repositories/5")
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
    @destination = Destinations::ArcLight.create!(
      name: "Test Destination",
      url: "https://example.com",
      collection: @collection
    )
  end

  test "belongs to destination and record" do
    transfer = Transfer.new
    assert_not transfer.valid?

    transfer.destination = @destination
    assert_not transfer.valid?

    transfer.record = @record
    assert transfer.valid?
  end

  test "has valid status enum values" do
    transfer = Transfer.where(destination: @destination, record: @record).first

    assert transfer.pending?

    transfer.succeeded!
    assert transfer.succeeded?

    transfer.failed!
    assert transfer.failed?
  end

  test "defaults to pending status" do
    transfer = Transfer.where(destination: @destination, record: @record).first
    assert transfer.pending?
  end
end