class RemoveOwnerFromCollections < ActiveRecord::Migration[8.0]
  def up
    remove_column :collections, :owner
  end

  def down
    add_column :collections, :owner, :string
  end
end
