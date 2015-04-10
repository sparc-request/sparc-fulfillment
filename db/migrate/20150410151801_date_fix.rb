class DateFix < ActiveRecord::Migration
  def change
    change_column :participants, :date_of_birth, :datetime
  end
end
