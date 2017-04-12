class AddAttachmentFileToImports < ActiveRecord::Migration
  def self.up
    change_table :imports do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :imports, :file
  end
end
