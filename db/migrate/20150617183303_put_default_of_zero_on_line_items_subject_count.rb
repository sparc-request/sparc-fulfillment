class PutDefaultOfZeroOnLineItemsSubjectCount < ActiveRecord::Migration
  def up
    change_column :line_items, :subject_count, :integer, default: 0
    LineItem.where(subject_count: nil).update_all(subject_count: 0)
  end

  def down
    change_column :line_items, :subject_count, :integer
  end
end
