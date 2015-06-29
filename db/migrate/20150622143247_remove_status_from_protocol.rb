class RemoveStatusFromProtocol < ActiveRecord::Migration
  def change
    remove_column :protocols, :status, :string
  end
end
