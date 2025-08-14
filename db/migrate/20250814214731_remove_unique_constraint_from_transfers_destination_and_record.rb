class RemoveUniqueConstraintFromTransfersDestinationAndRecord < ActiveRecord::Migration[8.0]
  def change
    # Remove the existing unique index
    remove_index :transfers, name: "index_transfers_on_destination_id_and_record_id"
    # Add a non-unique index
    add_index :transfers, ["destination_id", "record_id"], name: "index_transfers_on_destination_id_and_record_id"
  end
end
