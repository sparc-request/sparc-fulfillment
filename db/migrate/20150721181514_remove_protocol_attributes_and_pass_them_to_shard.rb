class RemoveProtocolAttributesAndPassThemToShard < ActiveRecord::Migration
  def change
    remove_column :protocols, :short_title
    remove_column :protocols, :title
  end
end
