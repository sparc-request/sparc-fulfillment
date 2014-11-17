class AddSubServiceRequestIdToProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :sparc_sub_service_request_id, :integer
  end
end
