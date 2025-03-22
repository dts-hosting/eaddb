class ChangeDatestampToDatetime < ActiveRecord::Migration[8.0]
  def up
    change_column :records, :modification_date, :datetime, precision: 6
  end

  def down
    change_column :records, :modification_date, :date
  end
end
