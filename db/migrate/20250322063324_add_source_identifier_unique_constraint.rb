class AddSourceIdentifierUniqueConstraint < ActiveRecord::Migration[8.0]
  def change
    remove_index :collections, [:source_id, :name]

    add_index :collections, [:source_id, :name], unique: true
    add_index :collections, [:source_id, :identifier], unique: true
  end
end
