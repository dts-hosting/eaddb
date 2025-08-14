require "test_helper"

class DestinationPendingTransfersTest < ActiveSupport::TestCase
  setup do
    @destination = create_destination

    @record_with_ead = create_record(collection: @destination.collection)
    @record_with_ead_ok = create_record(collection: @destination.collection)
    @record_with_ead_failed = create_record(collection: @destination.collection)
    @record_without_ead = create_record(collection: @destination.collection, ead_identifier: nil)
  end

  # TODO: reimplement
  test "returns transfers that are not succeeded and have EAD" do
    # pending_transfers = @destination.pending_transfers
  end

  # TODO: reimplement
  test "should be empty when all transfers have succeeded" do
    # assert_empty @destination.pending_transfers
  end

  # TODO: reimplement
  test "should be empty when no transfers have EAD ID" do
    # Record.update_all(ead_identifier: nil)
    #
    # assert_empty @destination.pending_transfers
  end
end
