class AddStatusToRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :records, :status, :string, null: false, default: "active"
  end
end
