class RenameSparcSubServiceRequestIdToSubServiceRequestId < ActiveRecord::Migration
  def change
    rename_column :protocols, :sparc_sub_service_request_id, :sub_service_request_id

    add_index "protocols", ["sub_service_request_id"], name: "index_protocols_on_sub_service_request_id", using: :btree
  end
end
