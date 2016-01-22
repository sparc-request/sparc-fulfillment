class StudyScheduleReport < Report

  VISIT_GROUP_OFFSET = 2

  def generate(document)
    @protocol = document.documentable

    document.update_attributes content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                               original_filename: "#{@attributes[:title]}.xlsx"

    p                     = Axlsx::Package.new
    wb                    = p.workbook
    default               = wb.styles.add_style alignment: { horizontal: :left }
    centered              = wb.styles.add_style alignment: { horizontal: :center }
    bordered              = wb.styles.add_style border: { style: :thin, color: '00000000' }
    centered_bordered     = wb.styles.add_style border: { style: :thin, color: '00000000' }, alignment: { horizontal: :center }
    row_header_style      = wb.styles.add_style b: true
    primary_header_style  = wb.styles.add_style sz: 12, b: true, bg_color: '0099FF', fg_color: 'FFFFFF', alignment: { horizontal: :left }
    header_centered_style = wb.styles.add_style sz: 12, b: true, bg_color: '0099FF', fg_color: 'FFFFFF', alignment: { horizontal: :center }
    sub_header_style      = wb.styles.add_style sz: 12, b: true, bg_color: 'E8E8E8', alignment: { horizontal: :left }
    arm_header_style      = wb.styles.add_style sz: 12, b: true, bg_color: 'ADADAD', alignment: { horizontal: :left }

    wb.add_worksheet(name: @attributes[:title].humanize) do |sheet|

      # Study Information header row
      sheet.add_row study_information_header_row, style: primary_header_style

      # Study Information metadata rows
      sheet.add_row study_information_id_row, style: default
      sheet.add_row study_information_title_row, style: default

      # Spacer row
      sheet.add_row

      # Arms
      arms.each do |arm|

        # Spacer row
        sheet.add_row

        # Arm header row
        sheet.add_row arm_header_row(arm), style: primary_header_style

        # Arm name row
        sheet.add_row arm_name_row(arm), style: arm_header_style

        # Arm R & T row
        sheet.add_row arm_r_t_row(arm), style: centered

        # Arm Service rows
        service_rows(arm).each do |service_row|
          sheet.add_row service_row
        end
      end
    end

    p.serialize(document.path)
  end

  def service_rows(arm)
    rows = Array.new
    visit_groups = arm.visit_groups
    r_quantities = visit_groups.map { |vg| vg.r_quantities_grouped_by_service }
    t_quantities  = visit_groups.map { |vg| vg.t_quantities_grouped_by_service }

    arm.line_items.each do |line_item|
      row             = Array.new

      row.push [
        line_item.service.name,
        line_item.subject_count,
        (r_quantities.map { |vg| vg[line_item.service.id] }).
          zip(t_quantities.map { |vg| vg[line_item.service.id] })
      ].flatten

      rows.push row.flatten
    end

    rows
  end

  def arm_r_t_row(arm)
    cells = [spacer_array(VISIT_GROUP_OFFSET)]

    arm.visit_count.times { cells.push ['R', 'T'] }

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
      'Selected Services',
      '# of Subjects',
      arm.visit_groups.map { |visit_group| [visit_group.name, ''] }
    ].flatten

    cells.push [
      spacer_array(max_width - cells.length),
    ]

    cells.flatten
  end

  def arms
    @protocol.arms
  end

  def study_information_header_row
    [
      [@protocol.class.to_s, 'information'].join(' '),
      spacer_array(max_width - 1)
    ].flatten
  end

  def study_information_id_row
    [
      [@protocol.class.to_s, 'ID:'].join(' '),
      @protocol.id
    ].flatten
  end

  def study_information_title_row
    [
      'Title:',
      @protocol.short_title
    ]
  end

  def file_name
    ['protocol', @protocol.id].join('_')
  end

  private

  def max_width
    VISIT_GROUP_OFFSET + (maximum_visit_count * 2)
  end

  def maximum_visit_count
    @protocol.arms.map(&:visit_count).max
  end

  def spacer_array(count)
    Array.new(count, '')
  end
end
