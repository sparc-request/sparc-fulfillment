class Note < ActiveRecord::Base

  KIND_TYPES    = %w(log note reason followup).freeze

  has_paper_trail
  acts_as_paranoid

  belongs_to :notable, polymorphic: true
  belongs_to :identity

  validates_inclusion_of :kind, in: KIND_TYPES
  
  validates :reason, presence: true, if: Proc.new { |note| ((note.notable_type == 'Procedure') || (note.notable_type == 'Appointment')) && note.kind == 'reason' }
  validates_inclusion_of :reason, in: Proc.new { |note| note.notable_type.constantize::NOTABLE_REASONS },
                                  if: Proc.new { |note| note.reason.present? }

  def comment
    case kind
    when 'followup'
      [
        'Followup',
        notable.task.due_at.strftime('%F'),
        read_attribute(:comment)
      ].compact.join(': ')
    when 'reason'
      [
        read_attribute(:reason),
        read_attribute(:comment)
      ].compact.join(': ')
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
