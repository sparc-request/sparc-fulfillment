class RenameProtocolsUdacProjectNumber < ActiveRecord::Migration
  def change
    rename_column :protocols, :udac_project_number, :udak_project_number
  end
end
