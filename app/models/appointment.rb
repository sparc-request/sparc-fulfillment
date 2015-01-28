class Appointment < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :participant
  belongs_to :visit_group
  has_many :procedures

  def build_procedures
    ActiveRecord::Base.transaction do
      if self.procedures.empty?
        
    end
  end

  def has_completed_procedures
    has_completed = false
    unless self.procedures.empty?
      self.procedures.each do |proc|
        if proc.completed_date
          has_completed = true
        end
      end
    end

    has_completed
  end
end