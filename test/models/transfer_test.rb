require "test_helper"

class TransferTest < ActiveSupport::TestCase
  setup do
    @collection = create_collection
    @record = create_record(collection: @collection)
    @destination = create_destination(attributes: {collection: @collection})
    @transfer = Transfer.find_by(record: @record, destination: @destination)
  end

  test "belongs to destination and record" do
    transfer = Transfer.new
    assert_not transfer.valid?

    transfer.destination = @destination
    assert_not transfer.valid?

    transfer.record = create_record
    assert transfer.valid?
  end

  test "has valid status enum values" do
    assert @transfer.pending?

    @transfer.succeeded!
    assert @transfer.succeeded?

    @transfer.failed!
    assert @transfer.failed?
  end

  test "defaults to pending status" do
    new_record = create_record(collection: @collection)
    new_transfer = Transfer.find_by(record: new_record, destination: @destination)

    assert new_transfer.pending?
  end
end
