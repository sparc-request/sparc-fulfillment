require 'csv'

class IncompleteVisitReport < Report

  REPORT_COLUMNS = [
    'Protocol ID (SRID)',
    'Patient Last Name',
    'Patient First Name',
    'Visit Name',
    'Start Date',
    'List of Cores which have incomplete visits'
  ].freeze

  def initialize(*)
    super
    @start_date = @attributes[:start_date]  || nil
    @end_date   = @attributes[:end_date]    || nil
  end

  def generate(document)
    appointments  = formatted_incomplete_appointments
    srids         = protocol_srids appointments

    document.update_attributes  content_type: 'text/csv',
                                original_filename: "#{@attributes[:title]}.csv"

    CSV.open(document.path, 'wb') do |csv|
      csv << REPORT_COLUMNS
      appointments.
        group_by { |x| x[0..3] }.
        map      { |x, y| [ srids[x[0]] ] + x[1..3] << y[0][4] << core_list(y) }.
        sort     { |x, y| x <=> y || 1 }. # by default, sort won't handle nils
        each     { |x| csv << x }
    end
  end

  def first_incomplete_visit
    Appointment.
      unscoped.
      where('start_date IS NOT NULL').
      joins(:procedures).
        where(procedures: { status: 'unstarted' }).
      order(created_at: :asc).
      limit(1).
      first
  end

  def last_incomplete_visit
    Appointment.
      unscoped.
      where('start_date IS NOT NULL').
      joins(:procedures).
        where(procedures: { status: 'unstarted' }).
      order(created_at: :desc).
      limit(1).
      first
  end

  def incomplete_appointments
    Appointment.
      unscoped.
      includes(:procedures).
      includes(:participant).
      where('start_date IS NOT NULL').
      where('start_date >= ?', start_at).
      where('start_date <= ?', end_at).
      joins(:participant).
      joins(:procedures).
        where(procedures: { status: 'unstarted' }).
      order(start_date: :desc).
      uniq
  end

  def formatted_incomplete_appointments
    appointments = Array.new

    incomplete_appointments.each do |incomplete_appointment|
      attributes = [
        incomplete_appointment.participant.protocol_id,
        incomplete_appointment.participant.last_name,
        incomplete_appointment.participant.first_name,
        incomplete_appointment.name,
        incomplete_appointment.start_date.strftime('%m/%d/%Y'),
        incomplete_appointment.procedures.first.sparc_core_name
      ]

      appointments.push attributes
    end

    appointments
  end

  def start_at
    if start_date.present?
      Time.parse start_date
    elsif first_incomplete_visit
      first_incomplete_visit.start_date
    else
      Time.current
    end
  end

  def end_at
    if end_date.present?
      Time.parse end_date
    elsif last_incomplete_visit
      last_incomplete_visit.start_date
    else
      Time.current
    end
  end

  private

  def protocol_srids(appointments)
    protocol_ids = appointments.map(&:first).uniq

    # SRID's indexed by protocol id
    @srid = Hash[Protocol.includes(:sub_service_request).
                  select(:id, :sparc_id, :sub_service_request_id). # cols necessary for SRID
                  where(id: protocol_ids).
                  map { |protocol| [protocol.id, protocol.srid] }]
  end

  def core_list(y)
    y.map(&:last).join(', ')
  end
end
