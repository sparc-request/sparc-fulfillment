class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.references :user, index: true
      t.references :protocol, index: true
      t.string :rights
      t.string :role
      t.string :role_other
      t.timestamps
      t.timestamp :deleted_at
    end
  end
end
