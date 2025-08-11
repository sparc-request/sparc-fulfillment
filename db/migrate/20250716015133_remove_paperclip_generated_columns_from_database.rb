class RemovePaperclipGeneratedColumnsFromDatabase < ActiveRecord::Migration[6.1]
  def change
    paperclip_columns = []
    paperclip_columns.concat(Import.column_names.grep(/(.+)_file_name$/)).compact
    paperclip_columns.concat(Import.column_names.grep(/(.+)_content_type$/)).compact
    paperclip_columns.concat(Import.column_names.grep(/(.+)_file_size$/)).compact
    paperclip_columns.concat(Import.column_names.grep(/(.+)_updated_at$/)).compact
    paperclip_columns.each do |c|
      remove_columns :"#{Import.table_name}", :"#{c}"
    end
  end
end
