# For Line Items with a one time fee and a Fulfillment,
# the name column will hold the name of the associated
# Service at the time the first Fulfillment was added.

class AddNameToLineItems < ActiveRecord::Migration
  def up
    add_column :line_items, :name, :string
    LineItem.find_each do |li|
      if li.has_fulfillments? && li.one_time_fee
        li.update_attributes(name: li.service.name)
      end
    end
  end

  def down
    remove_column :line_items, :name
  end
end
