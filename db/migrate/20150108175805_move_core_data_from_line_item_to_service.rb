class MoveCoreDataFromLineItemToService < ActiveRecord::Migration
  def change
    remove_column :line_items, :sparc_core_id, :integer
    remove_column :line_items, :sparc_core_name, :string
    add_column :services, :sparc_core_id, :integer
    add_column :services, :sparc_core_name, :string
  end
end
