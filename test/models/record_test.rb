require "test_helper"

class RecordTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @collection = create_collection
    @destination1 = create_destination(type: :arc_light, attributes: {collection: @collection})
    @destination2 = create_destination(type: :s3_bucket, attributes: {collection: @collection})

    @record_attributes = {
      collection: @collection,
      identifier: "id-123",
      ead_identifier: "ead-id-123",
      creation_date: Date.current,
      modification_date: Date.current,
      ead_xml: fixture_file_upload(Rails.root.join("test/fixtures/files/sample.xml"), "application/xml")
    }

    @record = Record.new(@record_attributes)
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

  test "identifier must be unique per collection" do
    @record.save
    duplicate = @record.dup
    refute duplicate.valid?
    assert_includes duplicate.errors[:identifier], "has already been taken"
  end

  test "identifier can be reused in different collections" do
    different_collection = create_collection
    record = Record.new(
      collection: different_collection,
      identifier: @record.identifier,
      creation_date: Date.current,
      modification_date: Date.current,
      ead_xml: fixture_file_upload(Rails.root.join("test/fixtures/files/sample.xml"), "application/xml")
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
    assert @record.transfers.all?(&:pending?)

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

  test "with_ead scope returns only records with ead attachment and identifier" do
    @record.save
    assert_includes Record.with_ead, @record
  end

  test "without_ead scope returns only records without ead attachment" do
    @record.ead_xml = nil
    @record.save
    assert_includes Record.without_ead, @record
  end

  test "without_ead scope returns only records without identifier" do
    @record.ead_identifier = nil
    @record.save
    assert_includes Record.without_ead, @record
  end
end
