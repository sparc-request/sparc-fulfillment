class RemoveSparcProgramColumnsFromLineItems < ActiveRecord::Migration
  def change
    remove_column :line_items, :name, :string
    remove_column :line_items, :cost, :integer
    remove_column :line_items, :sparc_program_id, :integer
    remove_column :line_items, :sparc_program_name, :string
  end
end
