class RemoveReportsTable < ActiveRecord::Migration
  def change
    drop_table :reports if ActiveRecord::Base.connection.table_exists? 'reports'
  end
end