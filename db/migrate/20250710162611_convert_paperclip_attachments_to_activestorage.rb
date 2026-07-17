class ConvertPaperclipAttachmentsToActivestorage < ActiveRecord::Migration[6.1]
  require 'open-uri'

  def change

    get_blob_id = "LAST_INSERT_ID()"

    get_service_name = Rails.application.config.active_storage.service

    blob_sql = "INSERT INTO active_storage_blobs (`key`, filename, content_type, metadata, service_name, byte_size, checksum, created_at) VALUES (?, ?, ?, '{}', '#{get_service_name}', ?, ?, ?)"

    attachment_sql = "INSERT INTO active_storage_attachments (name, record_type, record_id, blob_id, created_at) VALUES (?, ?, ?, #{get_blob_id}, ?)"

    active_storage_blob_statement = ActiveRecord::Base.connection.raw_connection.prepare(blob_sql)

    active_storage_attachment_statement = ActiveRecord::Base.connection.raw_connection.prepare(attachment_sql)

    attachments = Import.column_names.map do |c|
      if c =~ /(.+)_file_name$/
        $1
      end
    end.compact

    Import.find_each.each do |instance|
      attachments.each do |attachment|
        attachment_path = Dir[path_generator(instance, attachment)]
        if !attachment_path.empty?
          active_storage_blob_statement.execute(
            key(instance, attachment),
            instance.send("#{attachment}_file_name"),
            instance.send("#{attachment}_content_type"),
            instance.send("#{attachment}_file_size"),
            checksum(attachment_path[0]),
            instance.updated_at.strftime('%Y-%m-%d %H:%M:%S')
          )

          active_storage_attachment_statement.execute(
            attachment,
            Import.name,
            instance.id,
            instance.updated_at.strftime('%Y-%m-%d %H:%M:%S')
          )
        end
      end
    end

    active_storage_blob_statement.close
    active_storage_attachment_statement.close
    
  end

  private

  def key(instance, attachment)
    SecureRandom.uuid
  end

  def checksum(path)
    Digest::MD5.base64digest(File.read(path))
  end

  def path_generator(instance, attachment)
    filename = instance.send("#{attachment}_file_name")
    klass = instance.class.table_name
    id = instance.id
    id_partition = ("%09d".freeze % id).scan(/\d{3}/).join("/".freeze)

    Rails.root.join("public", "system", "#{klass}", "#{attachment.pluralize}", "#{id_partition}", "original", "*")
  end
end