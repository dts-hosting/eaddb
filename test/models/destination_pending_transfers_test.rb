require "test_helper"

class DestinationPendingTransfersTest < ActiveSupport::TestCase
  setup do
    @destination = create_destination

    @record_with_ead = create_record(collection: @destination.collection)
    @record_with_ead_ok = create_record(collection: @destination.collection)
    @record_with_ead_failed = create_record(collection: @destination.collection)
    @record_without_ead = create_record(collection: @destination.collection, ead_identifier: nil)

    Transfer.where(destination: @destination, record: @record_with_ead_ok).update(status: "succeeded")
    Transfer.where(destination: @destination, record: @record_with_ead_failed).update(status: "failed")
  end

  test "returns transfers that are not succeeded and have EAD" do
    pending_transfers = @destination.pending_transfers

    # Should include pending and failed transfers with EAD
    [@record_with_ead, @record_with_ead_failed].each do |record|
      assert_includes pending_transfers,
        Transfer.where(destination: @destination, record: record).first
    end

    # Should not include succeeded transfers or transfers without EAD
    [@record_with_ead_ok, @record_without_ead].each do |record|
      refute_includes pending_transfers,
        Transfer.where(destination: @destination, record: record).first
    end
  end

  test "should be empty when all transfers have succeeded" do
    @destination.transfers.update_all(status: "succeeded")

    assert_empty @destination.pending_transfers
  end

  test "should be empty when no transfers have EAD ID" do
    Record.update_all(ead_identifier: nil)

    assert_empty @destination.pending_transfers
  end
end
