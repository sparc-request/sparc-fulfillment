module ProtocolHelper

  def admin_portal_link(protocol)
    content_tag(:a, href: protocol.sparc_uri, target: :blank, class: 'btn btn-default btn-xs admin_portal_link', title: 'Admin Portal link', aria: { expanded: 'false' }) do
      content_tag(:span, '', class: 'glyphicon glyphicon-link')
    end
  end

  def formatted_status protocol
    if protocol.status.present?
      t(:sub_service_request)[:statuses][protocol.status.to_sym]
    else
      '-'
    end
  end

  def formatted_owner protocol
    if protocol.owner.present?
      protocol.owner.full_name
    else
      '-'
    end
  end

  def formatted_requester protocol
    if protocol.sub_service_request.present? && protocol.sub_service_request.service_request.present? && protocol.service_requester.present?
      protocol.service_requester.full_name
    else
      '-'
    end
  end

  def formatted_study_schedule_report protocol
    icon_span = raw content_tag(:span, '', class: "glyphicon glyphicon-equalizer")
    button    = raw content_tag(:button, raw(icon_span), type: 'button', class: 'btn btn-default btn-xs report-button study_schedule_report dropdown-toggle', id: "study_schedule_report_#{protocol.id.to_s}", 'aria-expanded' => 'false', title: 'Study Schedule Report', 'data-title' => 'Study Schedule Report', 'data-report_type' => 'study_schedule_report',  'data-documentable_id' => protocol.id, 'data-documentable_type' => 'Protocol', 'data-protocol_id' => protocol.id)
    ul        = raw content_tag(:ul, '', class: 'document-dropdown-menu hidden', id: "document_menu_study_schedule_report_#{protocol.id.to_s}", role: 'menu')
    html      = raw content_tag(:div, button + ul, class: 'btn-group')
  end

  def formatted_coordinators coordinators=Array.new
    html = '-'

    if coordinators.any?
      li = Array.new

      span = raw content_tag(:span, '', class: 'caret')
      button = raw content_tag(:button, raw('Coordinators ' + span), type: 'button', class: 'btn btn-default btn-xs dropdown-toggle', 'data-toggle' => 'dropdown', 'aria-expanded' => 'false')
      coordinators.each do |coordinator|
        li.push raw(content_tag(:li, raw(content_tag(:a, coordinator, href: 'javascript:;'))))
      end
      ul = raw content_tag(:ul, raw(li.join), class: 'dropdown-menu', role: 'menu')

      html = raw content_tag(:div, button + ul, class: 'btn-group')
    end

    html
  end

  def arm_per_participant_line_items_by_core arm, consolidated=false
    line_items = arm.line_items
    if consolidated && Sparc::Arm.where(id: arm.sparc_id).any?
      sparc_arm = Sparc::Arm.where(id: arm.sparc_id).first
      line_items += sparc_arm.line_items_visits.select{ |liv| liv.line_item.sub_service_request_id != arm.protocol.sub_service_request_id} # add pppv line items that aren't already in cwf
    end

    line_items.group_by{|li| li.service.organization}
  end

  def consolidated_one_time_fee_line_items protocol
    line_items = protocol.one_time_fee_line_items
    if Sparc::Protocol.where(id: protocol.sparc_id).any?
      sparc_protocol = Sparc::Protocol.where(id: protocol.sparc_id).first
      sparc_protocol.service_requests.each do |sr|
        line_items += sr.line_items.one_time_fee.select{ |li| li.sub_service_request_id != protocol.sub_service_request_id } # add otf line items that aren't already in cwf
      end
    end

    line_items
  end
end
