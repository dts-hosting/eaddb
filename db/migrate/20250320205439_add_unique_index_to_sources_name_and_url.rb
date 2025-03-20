class AddUniqueIndexToSourcesNameAndUrl < ActiveRecord::Migration[8.0]
  def change
    add_index :sources, [:name, :url], unique: true
  end
end
