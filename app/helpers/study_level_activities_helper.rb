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

  def sla_options_buttons line_item
    options = raw(
      note_list_item({object: line_item, has_notes: line_item.notes.any?})+
      content_tag(:li, raw(
        content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-open-file", aria: {hidden: "true"}))+' Documents', type: 'button', class: 'btn btn-default form-control actions-button documents list', data: {documentable_id: line_item.id, documentable_type: "LineItem"}))
      )+
      content_tag(:li, raw(
        content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-edit", aria: {hidden: "true"}))+' Edit Activity', type: 'button', class: 'btn btn-default form-control actions-button otf_edit'))
      )+
      content_tag(:li, raw(
        content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-remove", aria: {hidden: "true"}))+' Delete Activity', type: 'button', class: 'btn btn-default form-control actions-button otf_delete'))
      )
    )

    span = raw content_tag(:span, '', class: 'glyphicon glyphicon-triangle-bottom')
    button = raw content_tag(:button, raw(span), type: 'button', class: 'btn btn-default btn-sm dropdown-toggle form-control available-actions-button', 'data-toggle' => 'dropdown', 'aria-expanded' => 'false')
    ul = raw content_tag(:ul, options, class: 'dropdown-menu', role: 'menu')

    raw content_tag(:div, button + ul, class: 'btn-group overflow_webkit_button')
  end

  def fulfillments_drop_button line_item
    button = raw content_tag(:button, 'List', id: "list-#{line_item.id}", type: 'button', class: 'btn btn-success otf-fulfillment-list', title: 'List', type: "button", aria: {label: "List Fulfillments"}, data: {line_item_id: line_item.id})
  end

  def is_protocol_type_study? (protocol)
    protocol.protocol_type == 'Study'
  end

  def fulfillment_options_buttons fulfillment
    options = raw(
      note_list_item({object: fulfillment, has_notes: fulfillment.notes.any?})+
      content_tag(:li, raw(
        content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-open-file", aria: {hidden: "true"}))+' Documents', type: 'button', class: 'btn btn-default form-control actions-button documents list', data: {documentable_id: fulfillment.id, documentable_type: "Fulfillment"}))
      )+
      content_tag(:li, raw(
        content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-edit", aria: {hidden: "true"}))+' Edit Fulfillment', type: 'button', class: 'btn btn-default form-control actions-button otf_fulfillment_edit'))
      )
    )

    span = raw content_tag(:span, '', class: 'glyphicon glyphicon-triangle-bottom')
    button = raw content_tag(:button, raw(span), type: 'button', class: 'btn btn-default btn-sm dropdown-toggle form-control available-actions-button', 'data-toggle' => 'dropdown', 'aria-expanded' => 'false')
    ul = raw content_tag(:ul, options, class: 'dropdown-menu', role: 'menu')

    raw content_tag(:div, button + ul, class: 'btn-group')
  end

  def fulfillment_grouper_formatter fulfillment
    fulfillment.fulfilled_at.strftime('%b %Y')
  end

  def fulfillment_components_formatter components
    components.map(&:component).join(', ')
  end

  def fulfillment_date_formatter fulfillment
    if fulfillment.klok_entry_id.present? # this was imported from klok
      content_tag(:span, format_date(fulfillment.fulfilled_at), class: 'fulfillment-date-for-klok-entry') +
      content_tag(:i, '', class: 'glyphicon glyphicon-time')
    else
      format_date(fulfillment.fulfilled_at)
    end
  end

  private

  def note_list_item params
    content_tag(:li, raw(
      content_tag(:button,
        raw(content_tag(:span, '', class: "glyphicon glyphicon-list-alt #{params[:span_class].nil? ? "" : params[:span_class]} #{params[:has_notes] ? "blue-notes" : ""}", aria: {hidden: "true"}))+
        ' Notes', type: 'button', class: 'btn btn-default #{params[:button_class].nil? ? "" : params[:button_class]} form-control actions-button notes list', data: {notable_id: params[:object].id, notable_type: params[:object].class.name}))
    )
  end
end
