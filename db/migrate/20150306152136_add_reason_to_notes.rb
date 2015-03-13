class AddReasonToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :reason, :string
  end
end
