class AddTimestampsToDestinations < ActiveRecord::Migration[8.0]
  def change
    add_column :destinations, :started_at, :datetime
    add_column :destinations, :completed_at, :datetime
  end
end
