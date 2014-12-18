class AddSubjectCountToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :subject_count, :integer
  end
end
