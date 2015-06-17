class NotesCommentShouldBeText < ActiveRecord::Migration
  def change
    change_column :notes, :comment, :text
  end
end
