class Component < ActiveRecord::Base

  has_paper_trail if: Rails.env.production?
  acts_as_paranoid

  belongs_to :composable, polymorphic: true

  default_scope {order(:position)}

  validates :component, presence: true
end
