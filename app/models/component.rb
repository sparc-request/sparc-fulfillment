class Component < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid

  belongs_to :composable, polymorphic: true

end
