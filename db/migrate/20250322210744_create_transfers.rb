class CreateTransfers < ActiveRecord::Migration[8.0]
  def change
    create_table :transfers do |t|
      t.references :destination, null: false, foreign_key: true
      t.references :record, null: false, foreign_key: true
      t.integer :status, default: 0, null: false

      t.timestamps
    end
    add_index :transfers, [:destination_id, :record_id], unique: true
  end
end
