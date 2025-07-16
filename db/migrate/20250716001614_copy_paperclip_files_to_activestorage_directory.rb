class CopyPaperclipFilesToActivestorageDirectory < ActiveRecord::Migration[6.1]
  def change
    ActiveStorage::Attachment.find_each do |attachment|
      klass = attachment.record_type.downcase.pluralize
      id = attachment.record_id
      id_partition = ("%09d".freeze % id).scan(/\d{3}/).join("/".freeze)
      filename = attachment.blob.filename
      source = Rails.root.join("public", "system", "#{klass}", "#{attachment.name.pluralize}", "#{id_partition}", "original", "#{filename}")
      dest_dir = Rails.root.join("storage", attachment.blob.key.first(2), attachment.blob.key.first(4).last(2))
      dest = File.join(dest_dir, attachment.blob.key)
      
      FileUtils.mkdir_p(dest_dir)
      FileUtils.cp(source, dest)
    end
  end
end
