class DropClinicalProvidersTable < ActiveRecord::Migration
  def change
    drop_table :clinical_providers
  end
end
