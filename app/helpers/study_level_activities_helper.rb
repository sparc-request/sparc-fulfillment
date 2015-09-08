module StudyLevelActivitiesHelper

  def components_for_select components
    if components.empty?
      options_for_select(["This Service Has No Components"], disabled: "This Service Has No Components")
    else
      deleted_components = components.select{|c| c.deleted_at and c.selected } # deleted and selected
      visible_components = deleted_components + components.select{ |c| not c.deleted_at } # (deleted and selected) or not deleted
      options_from_collection_for_select( visible_components, 'id', 'component', selected: components.map{|c| c.id if c.selected}, disabled: deleted_components.map(&:id) )
    end
  end

  def sla_components_select line_item_id, components
    if components.any?
      select_tag "sla_#{line_item_id}_components", components_for_select(components), class: "sla_components selectpicker form-control", title: "Please Select", multiple: "", data:{container: "body", id: line_item_id, width: '150px', 'selected-text-format' => 'count>2'}
    else
      '-'
    end
  end

  def sla_options_buttons line_item_id
    content_tag(:button, class: 'btn btn-primary btn-sm notes list', title: t(:procedure)[:notes], type: "button", aria: {label: "Notes List"}, data: {notable_id: line_item_id, notable_type: "LineItem", toggle: "tooltip", animation: 'false'}) do
      content_tag(:span, '', class: "glyphicon glyphicon-list-alt", aria: {hidden: "true"})
    end +
    content_tag(:button, class: 'btn btn-primary btn-sm documents list', title: t(:documents)[:documents], type: "button", aria: {label: "Documents List"}, data: {documentable_id: line_item_id, documentable_type: "LineItem", toggle: "tooltip", animation: 'false'}) do
      content_tag(:span, '', class: "glyphicon glyphicon-open-file", aria: {hidden: "true"})
    end +
    content_tag(:button, class: 'btn btn-warning btn-sm otf_edit', title: t(:notes)[:lineitem][:edit], type: "button", aria: {label: "Edit Line Item"}, data: {toggle: "tooltip", animation: 'false'}) do
      content_tag(:span, '', class: "glyphicon glyphicon-edit", aria: {hidden: "true"})
    end +
    content_tag(:button, class: 'btn btn-danger btn-sm otf_delete', title: t(:line_item)[:delete_line_item], type: "button", aria: {label: "Delete Line Item"}, data: {toggle: "tooltip", animation: 'false'}) do
      content_tag(:span, '', class: "glyphicon glyphicon-remove", aria: {hidden: "true"})
    end
  end

  def fulfillments_drop_button line_item_id
    content_tag(:button, class: 'btn btn-primary btn-sm otf_fulfillments list', title: t(:fulfillment)[:view], type: "button", aria: {label: "Fulfillments List"}, data: {toggle: "tooltip", animation: 'false'}) do
      content_tag(:span, '', class: "glyphicon glyphicon-chevron-right", aria: {hidden: "true"})
    end
  end

  def fulfillment_components_dropdown components=Array.new
    html = '-'

    if components.any?
      li = Array.new

      span = raw content_tag(:span, '', class: 'caret')
      button = raw content_tag(:button, raw('Fulfillment Components ' + span), type: 'button', class: 'btn btn-default btn-xs dropdown-toggle', 'data-toggle' => 'dropdown', 'aria-expanded' => 'false')
      components.each do |c|
        li.push raw(content_tag(:li, raw(content_tag(:a, c.component, href: 'javascript:;'))))
      end
      ul = raw content_tag(:ul, raw(li.join), class: 'dropdown-menu', role: 'menu')

      html = raw content_tag(:div, button + ul, class: 'btn-group')
    end

    html
  end

  def fulfillment_options_buttons fulfillment_id
    content_tag(:button, class: 'btn btn-primary btn-sm notes list', title: t(:procedure)[:notes], type: "button", aria: {label: "Notes List"}, data: {notable_id: fulfillment_id, notable_type: "Fulfillment", toggle: "tooltip", animation: 'false'}) do
      content_tag(:span, '', class: "glyphicon glyphicon-list-alt", aria: {hidden: "true"})
    end +
    content_tag(:button, class: 'btn btn-primary btn-sm documents list', title: t(:documents)[:documents], type: "button", aria: {label: "Documents List"}, data: {documentable_id: fulfillment_id, documentable_type: "Fulfillment", toggle: "tooltip", animation: 'false'}) do
      content_tag(:span, '', class: "glyphicon glyphicon-open-file", aria: {hidden: "true"})
    end +
    content_tag(:button, class: 'btn btn-warning btn-sm otf_fulfillment_edit', title: t(:fulfillment)[:edit], type: "button", aria: {label: "Edit Fulfillment"}, data: {toggle: "tooltip", animation: 'false'}) do
      content_tag(:span, '', class: "glyphicon glyphicon-edit", aria: {hidden: "true"})
    end
  end
end