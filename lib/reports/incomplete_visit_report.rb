require 'csv'

class IncompleteVisitReport < Report
  VALIDATES_PRESENCE_OF     = [:title].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  def generate(document)
    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")

    CSV.open(document.path, "wb") do |csv|
      csv << ["Protocol ID (SRID)", "Patient Last Name", "Patient First Name", "Visit Name", "Start Date", "List of Cores which have incomplete visits"]

      Appointment.all.joins(:procedures).joins(:participant).joins(:visit_group).
        where('`appointments`.`start_date` < ? AND `procedures`.`status` = "incomplete"', DateTime.now.ago(24*60*60)).
        uniq.
        pluck('`participants`.`protocol_id`', '`participants`.`last_name`', '`participants`.`first_name`', :name, :start_date, :sparc_core_name).
        group_by { |x|    x[0..3] }.
        map      { |x, y| [Protocol.find(x[0]).srid] + x[1..3] << y[0][4].strftime('%m/%d/%Y') << y.map(&:last).join(', ') }.
        sort     { |a, b| a[0..3] <=> b[0..3] }.
        each     { |x|    csv << x }
    end
  end
end
