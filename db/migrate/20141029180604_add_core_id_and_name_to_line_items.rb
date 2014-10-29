class AddCoreIdAndNameToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :sparc_core_id, :integer
    add_column :line_items, :sparc_core_name, :string
  end
end
