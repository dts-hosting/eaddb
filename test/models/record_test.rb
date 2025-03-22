require "test_helper"

class RecordTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @collection = collections(:oai)
    @destination1 = Destinations::ArcLight.create!(
      name: "Destination 1",
      url: "https://example1.com",
      collection: @collection
    )
    @destination2 = Destinations::S3Bucket.create!(
      name: "Destination 2",
      url: "https://example2.com",
      collection: @collection
    )
    @ead_xml = fixture_file_upload(
      Rails.root.join("test/fixtures/files/sample.xml"),
      "application/xml"
    )
    @record = Record.new(
      collection: @collection,
      identifier: "unique-id-123",
      creation_date: Date.current,
      modification_date: Date.current,
      ead_xml: @ead_xml
    )
  end

  test "valid record" do
    assert @record.valid?
  end

  test "requires collection" do
    @record.collection = nil
    refute @record.valid?
    assert_includes @record.errors[:collection], "must exist"
  end

  test "requires identifier" do
    @record.identifier = nil
    refute @record.valid?
    assert_includes @record.errors[:identifier], "can't be blank"
  end

  test "requires ead_xml" do
    record = Record.new(
      collection: @collection,
      identifier: "unique-id-123"
    )
    refute record.valid?
    assert_includes record.errors[:ead_xml], "can't be blank"
  end

  test "identifier must be unique per collection" do
    @record.save
    duplicate = @record.dup
    refute duplicate.valid?
    assert_includes duplicate.errors[:identifier], "has already been taken"
  end

  test "identifier can be reused in different collections" do
    different_collection = collections(:api)
    record = Record.new(
      collection: different_collection,
      identifier: @record.identifier,
      creation_date: Date.current,
      modification_date: Date.current,
      ead_xml: @ead_xml
    )
    assert record.valid?
  end

  test "creation_date can be set" do
    @record.creation_date = Date.current
    assert @record.valid?
  end

  test "modification_date can be set" do
    @record.modification_date = Date.current
    assert @record.valid?
  end

  test "modification_date cannot be nil" do
    @record.modification_date = nil
    refute @record.valid?
  end

  test "creates transfers for all collection destinations after creation" do
    @record.save
    assert_equal @collection.destinations.count, @record.transfers.count
    assert @record.transfers.all? { |t| t.pending? }

    [@destination1, @destination2].each do |destination|
      assert Transfer.exists?(record: @record, destination: destination)
    end
  end

  test "resets transfer status to pending after update" do
    @record.save

    transfer = @record.transfers.first
    transfer.update!(status: :succeeded)
    assert transfer.succeeded?

    @record.update!(modification_date: Date.current)

    @record.transfers.reload.each do |t|
      assert t.pending?, "Transfer should be reset to pending after record update"
    end
  end
end
