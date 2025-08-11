class ColumnPreference < ApplicationRecord
  belongs_to :identity

  validates :column_name, presence: true
  validates :visible, inclusion: { in: [true, false] }
  validates :column_name, uniqueness: { scope: :identity_id, case_sensitive: true }

  scope :hidden, -> { where(visible: false) }

end
