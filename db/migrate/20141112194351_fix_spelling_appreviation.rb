class FixSpellingAppreviation < ActiveRecord::Migration
  def change
    rename_column :services, :appreviation, :abbreviation
  end
end
