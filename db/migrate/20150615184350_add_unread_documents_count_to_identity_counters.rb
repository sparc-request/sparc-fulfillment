class AddUnreadDocumentsCountToIdentityCounters < ActiveRecord::Migration
  def change
    add_column :identity_counters, :unaccessed_documents_count, :integer, default: 0
  end
end
