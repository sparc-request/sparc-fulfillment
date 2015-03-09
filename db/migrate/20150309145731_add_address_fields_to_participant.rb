class AddAddressFieldsToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :city, :string
    add_column :participants, :state, :string
    add_column :participants, :zipcode, :string
  end
end
