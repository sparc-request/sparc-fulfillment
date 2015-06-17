class ProtocolExporter

  include ActionView::Helpers::NumberHelper

  VISIT_GROUP_OFFSET  = 4
  TOTALS_OFFSET       = 2

  def initialize(protocol)
    @protocol = protocol
  end

  def service_rows(arm)
    rows = Array.new

    arm.line_items.each do |line_item|
      row             = Array.new
      sparc_line_item = Sparc::LineItem.find(line_item.sparc_id)

      row.push [
        line_item.service.name,
        number_to_currency(sparc_line_item.direct_costs_for_one_time_fee),
        number_to_currency(sparc_line_item.applicable_rate)
      ].flatten

      rows.push row.flatten
    end

    rows
  end

  def arm_r_t_row(arm)
    cells = [spacer_array(VISIT_GROUP_OFFSET)]

    arm.visit_count.times { cells.push ["R", "T"] }

    cells.flatten
  end

  def arm_name_row(arm)
    [
      arm.name,
      spacer_array(max_width - 1)
    ].flatten
  end

  def arm_header_row(arm)
    cells = [
      "Selected Services",
      "Current Cost",
      "Your Cost",
      "# of Subjects",
      arm.visit_groups.map { |visit_group| [visit_group.name, ""] }
    ].flatten

    cells.push [
      spacer_array(max_width - cells.length - TOTALS_OFFSET),
      "Total Per Patient",
      "Total Per Study"
    ]

    cells.flatten
  end

  def arms
    @protocol.arms
  end

  def study_information_header_row
    [
      [@protocol.class.to_s, "information"].join(" "),
      spacer_array(max_width - 1)
    ].flatten
  end

  def study_information_id_row
    [
      [@protocol.class.to_s, "ID:"].join(" "),
      @protocol.id
    ].flatten
  end

  def study_information_title_row
    [
      "Title:",
      @protocol.short_title
    ]
  end

  def file_name
    ["protocol", @protocol.id].join("_")
  end

  alias :worksheet_name :file_name

  private

  def justify(cells)

  end

  def max_width
    VISIT_GROUP_OFFSET + (maximum_visit_count * 2) + TOTALS_OFFSET
  end

  def has_per_patient_per_visit_services?
    @protocol.line_items_with_services(one_time_fee: false).any?
  end

  def maximum_visit_count
    @protocol.arms.map(&:visit_count).max
  end

  def spacer_array(count)
    Array.new(count, "")
  end
end
