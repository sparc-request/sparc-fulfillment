class Document < ActiveRecord::Base
  acts_as_paranoid

  do_not_validate_attachment_file_type :doc

  belongs_to :documentable, polymorphic: true
  has_attached_file :doc
end
