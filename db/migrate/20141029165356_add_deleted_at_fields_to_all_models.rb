class AddDeletedAtFieldsToAllModels < ActiveRecord::Migration
  def change
    add_column :protocols, :deleted_at, :datetime
    add_column :arms, :deleted_at, :datetime
    add_column :visit_groups, :deleted_at, :datetime
    add_column :services, :deleted_at, :datetime
    add_column :line_items, :deleted_at, :datetime
    add_column :visits, :deleted_at, :datetime
  end
end
