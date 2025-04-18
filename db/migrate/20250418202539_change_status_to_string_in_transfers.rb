class ChangeStatusToStringInTransfers < ActiveRecord::Migration[8.0]
  def up
    change_column :transfers, :status, :string, null: false
  end

  def down
    change_column :transfers, :status, :integer, null: false
  end
end
