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
end
