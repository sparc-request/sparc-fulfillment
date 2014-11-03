class AddMoreInfoToProtocols < ActiveRecord::Migration
  def change
    add_column :protocols, :irb_status, :string
    add_column :protocols, :irb_approval_date, :datetime
    add_column :protocols, :irb_expiration_date, :datetime
    add_column :protocols, :subsidy_amount, :integer
    add_column :protocols, :study_cost, :integer
  end
end
