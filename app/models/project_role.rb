class ProjectRole < ActiveRecord::Base

  belongs_to :identity
  belongs_to :protocol

  validates :rights,
            :role,
            presence: :true
end
