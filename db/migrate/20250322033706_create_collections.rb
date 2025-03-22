class CreateCollections < ActiveRecord::Migration[8.0]
  def change
    create_table :collections do |t|
      t.references :source, null: false, foreign_key: true
      t.string :name, null: false
      t.string :owner
      t.boolean :require_owner_in_record, default: false
      t.string :identifier, null: false
      t.timestamps
    end

    add_index :collections, [:source_id, :name], unique: true
    add_column :sources, :collections_count, :integer, default: 0, null: false
  end
end