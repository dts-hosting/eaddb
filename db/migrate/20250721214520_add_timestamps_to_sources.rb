class AddTimestampsToSources < ActiveRecord::Migration[8.0]
  def change
    add_column :sources, :started_at, :datetime
    add_column :sources, :completed_at, :datetime
  end
end
