class ChangeDatestampToDatetime < ActiveRecord::Migration[8.0]
  def change
    change_column :records, :modification_date, :datetime, precision: 6
  end
end
