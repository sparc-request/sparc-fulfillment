require 'csv'

class IncompleteVisitReport < Report
  VALIDATES_PRESENCE_OF     = [:title].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  # db columns of interest
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

    CSV.open(document.path, "wb") do |csv|
      csv << REPORT_COLUMNS

      Appointment.all.joins(:procedures).joins(:participant).joins(:visit_group).
        where("#{START_DATE} < ? AND #{STATUS} = \"incomplete\"", DateTime.now.ago(24*60*60)).
        uniq.
        pluck(PROTOCOL_ID, LAST_NAME, FIRST_NAME, VISIT_NAME, :start_date, :sparc_core_name).
        group_by { |x|    x[0..3] }.
        map      { |x, y| [ srid(x[0]) ] + x[1..3] << format_date(y[0][4]) << core_list(y) }.
        sort.
        each     { |x|    csv << x }
    end
  end

  def srid(protocol_id)
    Protocol.find(protocol_id).srid
  end

  def format_date(dt)
    dt.strftime('%m/%d/%Y')
  end

  def core_list(y)
    y.map(&:last).join(', ')
  end
end
