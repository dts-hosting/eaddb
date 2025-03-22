class AddTotalRecordsCountToSources < ActiveRecord::Migration[8.0]
  def change
    add_column :sources, :total_records_count, :integer, default: 0, null: false
  end
end