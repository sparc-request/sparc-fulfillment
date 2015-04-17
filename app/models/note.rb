class Note < ActiveRecord::Base

  KIND_TYPES    = %w(log note reason followup).freeze
<<<<<<< HEAD
  REASON_TYPES  = ['Assessment missed', 'Gender-specific assessment', 'Specimen/Assessment could not be obtained', 'Individual assessment completed elsewhere', 'Assessment not yet IRB approved', 'Duplicated assessment', 'Assessment performed by other personnel/study staff', 'Participant refused assessment', 'Assessment not performed due to equipment failure'].freeze
=======
  REASON_TYPES  = ["Assessment missed", "Assessment not performed due to equipment failure", "Assessment not yet IRB approved", "Assessment performed by other personnel/study staff", "Duplicated assessment", "Gender-specific assessment", "Individual assessment completed elsewhere","Participant refused assessment", "Specimen/Assessment could not be obtained"].freeze
>>>>>>> master

  has_paper_trail
  acts_as_paranoid

  belongs_to :notable, polymorphic: true
  belongs_to :user

  validates_inclusion_of :kind, in: KIND_TYPES
  validates_inclusion_of :reason, in: REASON_TYPES,
                                  if: Proc.new { |note| note.reason.present? }

  def comment
    case kind
    when 'followup'
      [
        'Followup',
        notable.follow_up_date.strftime('%F'),
        read_attribute(:comment)
      ].join(': ')
    else
      read_attribute(:comment)
    end
  end

  def reason?
    kind == 'reason'
  end

  def followup?
    kind == 'followup'
  end

  def log?
    kind == 'log'
  end

  def note?
    kind == 'note'
  end
end
