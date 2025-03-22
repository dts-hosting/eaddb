class CreateRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :records do |t|
      t.references :collection, null: false, foreign_key: true
      t.string :identifier, null: false
      t.date :creation_date
      t.date :modification_date, null: false

      t.timestamps
    end

    add_index :records, [:collection_id, :identifier], unique: true
    add_column :collections, :records_count, :integer, default: 0, null: false
  end
end
