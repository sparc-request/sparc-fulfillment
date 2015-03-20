class Note < ActiveRecord::Base

  KIND_TYPES    = %w(log note reason followup).freeze
  REASON_TYPES  = ['Skipped visit', 'Visit happened elsewhere', 'Patient missed visit', 'Visit happened outside of window', 'Assessment missed', 'Gender-specific assessment', 'Specimen/Assessment could not be obtained', 'Individual assessment completed elsewhere', 'Assessment not yet IRB approved', 'Duplicated assessment', 'Assessment performed by other personnel/study staff', 'Participant refused assessment', 'Assessment not performed due to equipment failure'].freeze

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
