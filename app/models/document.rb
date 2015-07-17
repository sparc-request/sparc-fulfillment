class Document < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :documentable, polymorphic: true

  def path
    [ENV.fetch('DOCUMENT_ROOT'), id].join('/')
  end

  def completed?
    state == 'Completed'
  end

  def downloaded?
    last_accessed_at
  end

  def belongs_to_identity?
    documentable_type == 'Identity'
  end

  def accessible_by?(identity)
    !belongs_to_identity? || (belongs_to_identity? && documentable == identity)
  end
end
