require 'csv'

class IncompleteVisitReport < Report

  # db columns of interest; qualified because of ambiguities
  START_DATE  = '`appointments`.`start_date`'
  STATUS      = '`procedures`.`status`'
  PROTOCOL_ID = '`participants`.`protocol_id`'
  LAST_NAME   = '`participants`.`last_name`'
  FIRST_NAME  = '`participants`.`first_name`'
  VISIT_NAME  = :name

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
    document.update_attributes  content_type: 'text/csv',
                                original_filename: "#{@attributes[:title]}.csv"
    _24_hours_ago = DateTime.now.ago(24*60*60)

    CSV.open(document.path, "wb") do |csv|
      csv << REPORT_COLUMNS

      result_set = Appointment.all.joins(:procedures).joins(:participant).joins(:visit_group).
                   where("#{START_DATE} < ? AND #{STATUS} = ?", _24_hours_ago, "unstarted").
                   uniq.
                   pluck(PROTOCOL_ID, LAST_NAME, FIRST_NAME, VISIT_NAME, :start_date, :sparc_core_name)

      get_protocol_srids(result_set)

      result_set.group_by { |x| x[0..3] }.
        map      { |x, y| [ @srid[x[0]] ] + x[1..3] << format_date(y[0][4]) << core_list(y) }.
        sort     { |x, y| x <=> y || 1 }. # by default, sort won't handle nils
        each     { |x|    csv << x }
    end
  end

  def first_incomplete_visit
    Appointment.
      unscoped.
      unstarted.
      order('created_at ASC').
      limit(1).
      first
  end

  def last_incomplete_visit
    Appointment.
      unscoped.
      unstarted.
      order('created_at DESC').
      limit(1).
      first
  end

  def incomplete_appointments
    @incomplete_appointments ||= Appointment.
                                  where('start_date IS NOT NULL').
                                  joins(:participant).
                                  joins(:procedures).
                                    where(procedures: { status: 'unstarted' }).
                                  order('start_date DESC').
                                  uniq
  end


  def start_at
    if start_date
      start_date
    else
      first_incomplete_visit.start_date
    end
  end

  def end_at
    if end_date
      end_date
    else
      last_incomplete_visit.start_date
    end
  end

  private

  def get_protocol_srids(result_set)
    protocol_ids = result_set.map(&:first).uniq

    # SRID's indexed by protocol id
    @srid = Hash[Protocol.includes(:sub_service_request).
                  select(:id, :sparc_id, :sub_service_request_id). # cols necessary for SRID
                  where(id: protocol_ids).
                  map { |protocol| [protocol.id, protocol.srid] }]
  end

  def format_date(dt)
    dt.strftime('%m/%d/%Y')
  end

  def core_list(y)
    y.map(&:last).join(', ')
  end
end
