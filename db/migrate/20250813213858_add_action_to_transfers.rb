class AddActionToTransfers < ActiveRecord::Migration[8.0]
  def change
    add_column :transfers, :action, :string, default: "export", null: false
  end
end
