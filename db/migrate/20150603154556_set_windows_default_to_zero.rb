class SetWindowsDefaultToZero < ActiveRecord::Migration
  def change
    change_column :visit_groups, :window_before, :integer, default: 0
    change_column :visit_groups, :window_after, :integer, default: 0
  end
end
