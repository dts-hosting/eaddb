require "test_helper"

class DestinationPendingDeletesTest < ActiveSupport::TestCase
  setup do
    @destination = create_destination

    @record_deleted = create_record(collection: @destination.collection, status: "deleted")
    @record_deleted_ok = create_record(collection: @destination.collection, status: "deleted")
    @record_deleted_failed = create_record(collection: @destination.collection, status: "deleted")
    @record_deleted_without_ead = create_record(collection: @destination.collection, status: "deleted", ead_identifier: nil)
    @record_active = create_record(collection: @destination.collection, status: "active")
  end

  # TODO: reimplement
  test "returns transfers for deleted records that are not succeeded and have EAD" do
    # pending_deletes = @destination.pending_deletes

    # Should include pending and failed transfers for deleted records with EAD

    # Should not include succeeded transfers, transfers without EAD, or transfers for active records
  end

  # TODO: reimplement
  test "should be empty when all transfers for deleted records have succeeded" do
    # Transfer.joins(:record)
    #   .where(record: {status: "deleted"})
    #   .update_all(status: "succeeded")
    #
    # assert_empty @destination.pending_deletes
  end

  # TODO: reimplement
  test "should be empty when no deleted records have EAD ID" do
    # Record.where(status: "deleted").update_all(ead_identifier: nil)
    #
    # assert_empty @destination.pending_deletes
  end

  # TODO: reimplement
  test "should be empty when there are no deleted records" do
    # Record.update_all(status: "active")
    #
    # assert_empty @destination.pending_deletes
  end
end
