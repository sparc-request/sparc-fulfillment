module ProtocolHelper

  def formatted_coordinators(coordinators=Array.new)
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

  def arm_per_participant_line_items_by_core(arm, consolidated=false)
    line_items = arm.line_items
    if consolidated && Sparc::Arm.where(id: arm.sparc_id).any?
      sparc_arm = Sparc::Arm.where(id: arm.sparc_id).first
      line_items += sparc_arm.line_items_visits.select{ |liv| liv.line_item.sub_service_request_id != arm.protocol.sub_service_request_id} # add pppv line items that aren't already in cwf
    end

    line_items.group_by{|li| li.service.organization}
  end

  def consolidated_one_time_fee_line_items(protocol)
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
