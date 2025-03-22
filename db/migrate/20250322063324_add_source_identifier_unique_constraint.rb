class AddSourceIdentifierUniqueConstraint < ActiveRecord::Migration[8.0]
  def up
    remove_index :collections, [:source_id, :name] if index_exists?(:collections, [:source_id, :name])

    add_index :collections, [:source_id, :name], unique: true
    add_index :collections, [:source_id, :identifier], unique: true
  end

  def down
    remove_index :collections, [:source_id, :identifier]
    remove_index :collections, [:source_id, :name]
    add_index :collections, [:source_id, :name]
  end
end
