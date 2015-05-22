class ChangeFulfillmentsCreatedByToUserId < ActiveRecord::Migration
  def change
    remove_column :fulfillments, :created_by, :integer
    add_column :fulfillments, :creator_id, :integer
    add_index :fulfillments, :creator_id
    remove_column :fulfillments, :performed_by, :integer
    add_column :fulfillments, :performer_id, :integer
    add_index :fulfillments, :performer_id
  end
end
