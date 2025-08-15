require "test_helper"

class TransferTest < ActiveSupport::TestCase
  setup do
    @collection = create_collection
    @record = create_record(collection: @collection)
    @destination = create_destination(attributes: {collection: @collection})
    @transfer = Transfer.create(action: "export", record: @record, destination: @destination)
  end

  test "belongs to destination and record" do
    assert @transfer.valid?
  end

  test "has valid status enum values" do
    assert @transfer.pending?

    @transfer.succeeded!
    assert @transfer.succeeded?

    @transfer.failed!
    assert @transfer.failed?
  end

  test "defaults to pending status" do
    assert @transfer.pending?
  end
end
