class Arm < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :protocol

  has_many :line_items, :dependent => :destroy
  has_many :visit_groups, :dependent => :destroy
  has_many :participants

  accepts_nested_attributes_for :line_items, :visit_groups

  validates :name, presence: true
  validates_numericality_of :subject_count, greater_than_or_equal_to: 1
  validates_numericality_of :visit_count, greater_than_or_equal_to: 1

  after_create :create_visit_groups



  private
  def create_visit_groups
    new_visit_groups = []
    for count in 1..self.visit_count
      new_visit_groups << VisitGroup.new(name: "Visit "+ count.to_s, day: count, position: count, arm_id: self.id)
    end
    VisitGroup.import new_visit_groups
  end
end
