class AddTransferOnImportToSources < ActiveRecord::Migration[8.0]
  def change
    add_column :sources, :transfer_on_import, :boolean, default: false, null: false
  end
end
