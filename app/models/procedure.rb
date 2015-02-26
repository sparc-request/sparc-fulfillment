class Procedure < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :appointment
  belongs_to :visit

  has_many :notes
  has_many :tasks

  scope :untouched,   -> { where('status IS NULL')              }
  scope :incomplete,  -> { where('completed_date IS NULL')      }
  scope :complete,    -> { where('completed_date IS NOT NULL')  }

  def destroy
    if self.status.blank?
      super
    else
      raise ActiveRecord::ActiveRecordError
    end
  end

  def self.billing_display
    [["R", "research_billing_qty"],
     ["T", "insurance_billing_qty"],
     ["O", "other_billing_qty"]]
  end

  def display_follow_up
    self.follow_up_date.strftime('%x') unless self.follow_up_date.blank?
  end
end
