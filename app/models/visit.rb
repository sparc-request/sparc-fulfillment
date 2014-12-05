class Visit < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :line_item
  belongs_to :visit_group

  def position
    visit_group.position
  end
end
