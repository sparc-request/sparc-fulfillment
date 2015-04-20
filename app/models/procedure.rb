class Procedure < ActiveRecord::Base

  STATUS_TYPES = %w(complete incomplete).freeze

  has_paper_trail
  acts_as_paranoid

  has_one :protocol,    through: :appointment
  has_one :arm,         through: :appointment
  has_one :participant, through: :appointment
  has_one :visit_group, through: :appointment

  belongs_to :appointment
  belongs_to :visit

  has_many :notes, as: :notable
  has_many :tasks, as: :assignable

  validates_inclusion_of :status, in: STATUS_TYPES,
                                  if: Proc.new { |procedure| procedure.status.present? }
  validates :follow_up_date, presence: true, on: :update
  accepts_nested_attributes_for :notes
  accepts_nested_attributes_for :tasks

  scope :untouched,   -> { where('status IS NULL')              }
  scope :incomplete,  -> { where('completed_date IS NULL')      }
  scope :complete,    -> { where('completed_date IS NOT NULL')  }

  def follow_up_date=(follow_up)
    write_attribute(:follow_up_date, Time.strptime(follow_up, "%m-%d-%Y")) if follow_up.present?
  end

  def self.billing_display
    [["R", "research_billing_qty"],
     ["T", "insurance_billing_qty"],
     ["O", "other_billing_qty"]]
  end

  def update_attributes(attributes)
    if attributes[:status].present? &&
        attributes[:status] == "complete" &&
        (incomplete? || status.nil? || reset?)
      attributes.merge!(completed_date: Time.current)
    elsif attributes[:status].blank? &&
        attributes[:status] == ''
      attributes.merge!(completed_date: nil)
    end

    super attributes
  end

  def reset?
    status == ''
  end

  def complete?
    status == 'complete'
  end

  def incomplete?
    status == 'incomplete'
  end

  def destroy
    if status.blank?
      super
    else
      raise ActiveRecord::ActiveRecordError
    end
  end
end
