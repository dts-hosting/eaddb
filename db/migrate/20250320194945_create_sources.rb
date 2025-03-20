class CreateSources < ActiveRecord::Migration[8.0]
  def change
    create_table :sources do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.string :username
      t.string :password
      t.string :type, null: false

      t.timestamps
    end

    add_index :sources, :name
    add_index :sources, :type
  end
end
