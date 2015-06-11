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

  def display_cost(cost)
    dollars = (cost / 100) rescue nil

    number_to_currency(dollars, seperator: ",")
  end

  def arm_per_patient_line_items_by_core(arm, consolidated=false)
    if consolidated
      sparc_arm = Sparc::Arm.where(id: arm.sparc_id).first
      line_items = sparc_arm.line_items_visits.select{ |liv| liv.line_item.sub_service_request_id != arm.protocol.sub_service_request_id}
      line_items += arm.line_items
    else
      line_items = arm.line_items.includes(:service).where(:services => {:one_time_fee => false})
    end

    line_items.group_by{|li| li.service.organization}
  end
end
