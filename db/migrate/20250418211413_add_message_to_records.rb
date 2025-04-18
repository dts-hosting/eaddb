class AddMessageToRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :records, :message, :string
  end
end
