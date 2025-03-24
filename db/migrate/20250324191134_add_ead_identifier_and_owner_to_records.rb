class AddEadIdentifierAndOwnerToRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :records, :ead_identifier, :string
    add_column :records, :owner, :string
    add_index :records, :ead_identifier
    add_index :records, :owner
  end
end
