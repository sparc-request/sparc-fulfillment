class Document < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :documentable, polymorphic: true
  has_attached_file :doc

  validates_attachment_presence :doc
  do_not_validate_attachment_file_type :doc
end
