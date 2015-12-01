class Document < ActiveRecord::Base

  acts_as_paranoid

  attr_accessor :start_date, :end_date

  belongs_to :documentable, polymorphic: true

  def path
    [ENV.fetch('DOCUMENTS_FOLDER'), id].join('/')
  end

  def completed?
    state == 'Completed'
  end

  def failed?
    state == 'Error'
  end

  def downloaded?
    last_accessed_at
  end

  def accessible_by?(identity)
    !(documentable_type == 'Identity') || (documentable_type == 'Identity' && documentable == identity)
  end

  def participant_report?
    kind == 'participant_report'
  end

  def study_schedule_report?
    kind == 'study_schedule_report'
  end
end
