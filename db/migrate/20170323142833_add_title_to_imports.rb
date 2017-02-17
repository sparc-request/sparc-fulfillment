class AddTitleToImports < ActiveRecord::Migration
  def change
    add_column :imports, :title, :string
  end
end
