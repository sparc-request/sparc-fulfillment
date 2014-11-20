class AddStatusToProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :status, :string
  end
end
