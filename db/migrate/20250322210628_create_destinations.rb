class CreateDestinations < ActiveRecord::Migration[8.0]
  def change
    create_table :destinations do |t|
      t.string :type, null: false
      t.string :name, null: false
      t.string :url, null: false
      t.string :identifier
      t.string :username
      t.string :password
      t.references :collection, null: false, foreign_key: true

      t.timestamps
    end
    add_index :destinations, [:name, :type], unique: true
  end
end
