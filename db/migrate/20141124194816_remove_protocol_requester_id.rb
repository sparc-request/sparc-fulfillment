class RemoveProtocolRequesterId < ActiveRecord::Migration
  def change
    remove_column :protocols, :requester_id, :integer
  end
end
