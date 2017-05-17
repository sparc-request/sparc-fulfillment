class AddAttachmentXmlFileToImports < ActiveRecord::Migration
  def self.up
    change_table :imports do |t|
      t.attachment :xml_file
    end
  end

  def self.down
    remove_attachment :imports, :xml_file
  end
end
