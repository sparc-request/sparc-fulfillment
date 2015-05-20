class RenameReportsUserIdToIdentityId < ActiveRecord::Migration
  def change
    rename_column :reports, :user_id, :identity_id
  end
end
