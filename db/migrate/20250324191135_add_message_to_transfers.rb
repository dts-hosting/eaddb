class AddMessageToTransfers < ActiveRecord::Migration[8.0]
  def change
    add_column :transfers, :message, :string
  end
end
