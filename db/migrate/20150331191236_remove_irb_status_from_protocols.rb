class RemoveIrbStatusFromProtocols < ActiveRecord::Migration
  def change
    remove_column :protocols, :irb_status, :string
  end
end
