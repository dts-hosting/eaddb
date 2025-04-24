class AddStatusToSourcesAndDestinations < ActiveRecord::Migration[8.0]
  def change
    add_column :sources, :message, :string
    add_column :sources, :status, :string, null: false, default: "active"

    add_column :destinations, :message, :string
    add_column :destinations, :status, :string, null: false, default: "active"
  end
end
