class ChangeCollationOnParticipants < ActiveRecord::Migration[5.2]
  def change
    change_column :participants, :last_name, "VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    change_column :participants, :first_name, "VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci"
  end
end
