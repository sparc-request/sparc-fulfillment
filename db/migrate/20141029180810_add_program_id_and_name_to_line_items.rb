class AddProgramIdAndNameToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :sparc_program_id, :integer
    add_column :line_items, :sparc_program_name, :string
  end
end
