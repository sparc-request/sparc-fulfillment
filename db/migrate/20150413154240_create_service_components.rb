class CreateServiceComponents < ActiveRecord::Migration
  def change
    create_table :service_components do |t|
      t.string :service_component
    end
  end
end
