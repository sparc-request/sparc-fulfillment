class AddComponentNameToTimeTrackings < ActiveRecord::Migration[7.2]
  def change
    add_column :time_trackings, :component_name, :string
    remove_column :time_trackings, :component_id, :integer
  end
end
