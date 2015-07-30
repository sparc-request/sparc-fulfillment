class Procedure < ActiveRecord::Base

  STATUS_TYPES = %w(complete incomplete follow_up unstarted).freeze

  NOTABLE_REASONS  = ['Assessment missed', 'Gender-specific assessment', 'Specimen/Assessment could not be obtained',
                      'Individual assessment completed elsewhere', 'Assessment not yet IRB approved', 'Duplicated assessment',
                      'Assessment performed by other personnel/study staff', 'Participant refused assessment',
                      'Assessment not performed due to equipment failure', 'Not collected/not done--unknown reason'].freeze

  has_paper_trail
  acts_as_paranoid

  has_one :protocol,    through: :appointment
  has_one :arm,         through: :appointment
  has_one :participant, through: :appointment
  has_one :visit_group, through: :appointment
  has_one :task,        as: :assignable, dependent: :destroy

  belongs_to :appointment
  belongs_to :visit
  belongs_to :service
  belongs_to :performer, class_name: "Identity"

  has_many :notes, as: :notable
  has_many :tasks, as: :assignable

  before_update :set_status_dependencies

  validates_inclusion_of :status, in: STATUS_TYPES,
                                  if: Proc.new { |procedure| procedure.status.present? }

  accepts_nested_attributes_for :notes

  scope :untouched,   -> { where(status: 'unstarted') }
  scope :incomplete,  -> { where(status: 'incomplete') }
  scope :complete,    -> { where(status: 'complete') }

  # select Procedures that belong to an Appointment without a start date
  scope :belonging_to_unbegun_appt, -> { joins(:appointment).where('appointments.start_date IS NULL') }
  scope :completed_r_in_date_range, ->(start_date, end_date) {
        where("procedures.completed_date is not NULL AND DATE(procedures.completed_date) between ? AND ? AND billing_type = ?", start_date.to_date, end_date.to_date, "research_billing_qty")}

  def self.billing_display
    [["R", "research_billing_qty"],
     ["T", "insurance_billing_qty"],
     ["O", "other_billing_qty"]]
  end

  def formatted_billing_type
    case self.billing_type
    when "research_billing_qty"
      return "R"
    when "insurance_billing_qty"
      return "T"
    when "other_billing_qty"
      return "O"
    end
  end

  # Has this procedure's appointment started?
  def appt_started?
    appointment.start_date.present?
  end

  def handled_date
    if complete?
      return completed_date
    elsif incomplete?
      return incompleted_date
    elsif follow_up?
      return task.created_at
    else
      return nil
    end
  end

  def follow_up_date
    if task.present?
      return task.due_at
    else
      return nil
    end
  end

  #TODO: The following 4 methods should be redefined as scopes
  def complete?
    status == 'complete'
  end

  def incomplete?
    status == 'incomplete'
  end

  def follow_up?
    status == 'follow_up'
  end

  def unstarted?
    status == 'unstarted'
  end

  def reason_note
    if incomplete?
      notes.select{|note| note.reason?}.last
    end
  end

  def destroy
    if unstarted?
      super
    else
      raise ActiveRecord::ActiveRecordError
    end
  end

  def completed_date=(completed_date)
    if completed_date.present?
      write_attribute(:completed_date, Time.strptime(completed_date, "%m-%d-%Y"))
    else
      write_attribute(:completed_date, nil)
    end
  end

  def service_name
    if unstarted?
      service.present? ? service.name : ''
    else
      read_attribute(:service_name)
    end
  end

  def cost(funding_source = protocol.funding_source, date = Time.current)
    if service_cost
      amount = service_cost
    else
      if visit
        amount = visit.line_item.cost(funding_source, date)
      else
        amount = service.cost(funding_source, date)
      end
    end
    amount.to_i
  end

  private

  def set_status_dependencies
    if status_changed?(from: "unstarted") && service.present?
      write_attribute(:service_name, service.name)
    end

    if status_changed?(to: "complete")
      write_attribute(:incompleted_date, nil)
      write_attribute(:completed_date, Date.today)
      write_attribute(:service_cost, cost)
    elsif status_changed?(to: "incomplete")
      write_attribute(:completed_date, nil)
      write_attribute(:incompleted_date, Date.today)
    elsif status_changed?(to: "unstarted") or status_changed?(to: "follow_up")
      write_attribute(:completed_date, nil)
      write_attribute(:incompleted_date, nil)
      if task.present?
        write_attribute(:status, "follow_up")
      end
    end

    if status_changed?(from: "complete")
      write_attribute(:service_cost, nil)
    end
  end
end
