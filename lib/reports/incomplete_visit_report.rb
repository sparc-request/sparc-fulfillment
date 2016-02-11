require 'csv'

class IncompleteVisitReport < Report
  VALIDATES_PRESENCE_OF     = [:title].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  # db columns of interest; qualified because of ambiguities
  START_DATE  = '`appointments`.`start_date`'
  STATUS      = '`procedures`.`status`'
  PROTOCOL_ID = '`participants`.`protocol_id`'
  LAST_NAME   = '`participants`.`last_name`'
  FIRST_NAME  = '`participants`.`first_name`'
  VISIT_NAME  = :name

  # report columns
  REPORT_COLUMNS = ["Protocol ID (SRID)", "Patient Last Name", "Patient First Name", "Visit Name", "Start Date", "List of Cores which have incomplete visits"]

  def generate(document)
    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")
    _24_hours_ago = 24.hours.ago.utc

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

  def get_protocol_srids(result_set)
    protocol_ids = result_set.map(&:first).uniq

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
