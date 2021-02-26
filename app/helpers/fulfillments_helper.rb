# Copyright © 2011-2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

module FulfillmentsHelper
  def fulfillment_options_buttons(fulfillment)
    unless fulfillment.invoiced?
      options = raw(
        note_list_item({object: fulfillment, has_notes: fulfillment.notes.any?})+
        document_list_item({object: fulfillment, has_documents: fulfillment.documents.any?})+
        content_tag(:li, raw(
          content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-edit", aria: {hidden: "true"}))+' Edit Fulfillment', type: 'button', class: 'btn btn-default form-control actions-button otf_fulfillment_edit'))
        )+
        content_tag(:li, raw(
                      content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-remove", aria: {hidden: "true"}))+' Delete Fulfillment', type: 'button', class: 'btn btn-default form-control actions-button otf_fulfillment_delete', data: { id: fulfillment.id }))
        )
      )
    else
      options = raw(
        note_list_item({object: fulfillment, has_notes: fulfillment.notes.any?})+
        content_tag(:li, raw(
          content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-open-file", aria: {hidden: "true"}))+' Documents', type: 'button', class: 'btn btn-default form-control actions-button documents list', data: {documentable_id: fulfillment.id, documentable_type: "Fulfillment"}))
        )
      )
    end

    span = raw content_tag(:span, '', class: 'glyphicon glyphicon-triangle-bottom')
    button = raw content_tag(:button, raw(span), type: 'button', class: 'btn btn-default btn-sm dropdown-toggle form-control available-actions-button', 'data-toggle' => 'dropdown', 'aria-expanded' => 'false')
    ul = raw content_tag(:ul, options, class: 'dropdown-menu', role: 'menu')

    raw content_tag(:div, button + ul, class: 'btn-group')
  end

  def format_fulfillment_invoiced(fulfillment)
    if current_identity.billing_manager_protocols.include?(fulfillment.protocol)
      content_tag(:input, '', type: "checkbox", name: "invoiced", checked: fulfillment.invoiced?, data: {toggle: 'toggle', on: "Yes", off: "No", id: fulfillment.id}, disabled: fulfillment.invoiced? || fulfillment.credited?, class: 'invoice_toggle')
    else
      fulfillment.invoiced? ? t('constants.yes_select') : t('constants.no_select')
    end
  end

  def format_fulfillment_credited(fulfillment)
    if current_identity.billing_manager_protocols_allow_credit.include?(fulfillment.protocol)
      content_tag(:input, '', type: "checkbox", name: "credited", checked: fulfillment.credited?, data: {toggle: 'toggle', on: "Yes", off: "No", id: fulfillment.id}, disabled: fulfillment.credited? || fulfillment.invoiced?, class: 'credit_toggle')
    else
      fulfillment.credited? ? t('constants.yes_select') : t('constants.no_select')
    end
  end

  def fulfillment_grouper_formatter(fulfillment)
    fulfillment.fulfilled_at.strftime('%b %Y')
  end

  def fulfillment_components_formatter(components)
    components.map(&:component).join(', ')
  end

  def fulfillment_date_formatter(fulfillment)
    if fulfillment.klok_entry_id.present? # this was imported from klok
      content_tag(:span, format_date(fulfillment.fulfilled_at), class: 'fulfillment-date-for-klok-entry') +
      content_tag(:i, '', class: 'glyphicon glyphicon-time')
    else
      format_date(fulfillment.fulfilled_at)
    end
  end

  private

  def note_list_item(params)
    content_tag(:li, raw(
      content_tag(:button,
        raw(content_tag(:span, '', id: "#{params[:object].class.name.downcase}_#{params[:object].id}_notes", class: "glyphicon glyphicon-list-alt #{params[:has_notes] ? 'blue-glyphicon' : ''}", aria: {hidden: "true"}))+
        ' Notes' + show_notification_badge(params, 'notes'),
        type: 'button', class: "btn btn-default form-control actions-button notes list", style: 'position: relative', data: {notable_id: params[:object].id, notable_type: params[:object].class.name}))
    )
  end

  def document_list_item(params)
    content_tag(:li, raw(
      content_tag(:button,
        raw(content_tag(:span, '', id: "#{params[:object].class.name.downcase}_#{params[:object].id}_documents", class: "glyphicon glyphicon-open-file #{params[:has_documents] ? 'blue-glyphicon' : ''}", aria: {hidden: "true"}))+
        ' Documents' + show_notification_badge(params, 'documents'),
        type: 'button', class: "btn btn-default form-control actions-button documents list", style: 'position: relative', data: {documentable_id: params[:object].id, documentable_type: params[:object].class.name}))
    )
  end

  def show_notification_badge(params, type)
    if type == 'notes' && params[:has_notes]
      raw(content_tag(:span, params[:object].notes.count, class:'notification orange-badge-notes'))
    elsif type == 'documents' && params[:has_documents]
      raw(content_tag(:span, params[:object].documents.count, class:'notification orange-badge-documents'))
    end
  end
end
