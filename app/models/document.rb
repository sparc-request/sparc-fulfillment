class Document < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :documentable, polymorphic: true

  def path
    [ENV.fetch('DOCUMENTS_FOLDER'), id].join('/')
  end

  def completed?
    state == 'Completed'
  end

  def downloaded?
    last_accessed_at
  end
  
  def accessible_by?(identity)
    !(documentable_type == 'Identity') || (documentable_type == 'Identity' && documentable == identity)
  end
end
