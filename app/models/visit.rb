class Visit < ActiveRecord::Base
  self.per_page = 6

  acts_as_paranoid

  belongs_to :line_item
  belongs_to :visit_group

  def position
    visit_group.position
  end
end
