# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

$ ->

  allowSubmit = true
  # Line Item Bindings

  $(document).on 'click', ".otf_service_new", ->
    protocol_id = $('#protocol_id').val()
    data = protocol_id: protocol_id
    $.ajax
      type: 'GET'
      url: "/line_items/new"
      data: data

  $(document).on 'change', '.components .sla_components > .selectpicker', ->
    row_index   = $(this).parents("tr").data("index")
    line_item_id = $(this).parents("table.study_level_activities").bootstrapTable("getData")[row_index].id
    data = components: $(this).val(), line_item_id: line_item_id
    $.ajax
      type: 'PUT'
      url: "/components/update"
      data: data

  $(document).on 'click', '.otf_edit', ->
    row_index   = $(this).parents("tr").data("index")
    line_item_id = $(this).parents("table.study_level_activities").bootstrapTable("getData")[row_index].id
    $.ajax
      type: 'GET'
      url: "/line_items/#{line_item_id}/edit"

  $(document).on 'click', '.otf_delete', ->
    row_index   = $(this).parents("tr").data("index")
    line_item_id = $(this).parents("table.study_level_activities").bootstrapTable("getData")[row_index].id
    del = confirm "Are you sure you want to delete the selected Study Level Activity from this protocol"
    if del
      $.ajax
        type: "DELETE"
        url: "/line_items/#{line_item_id}"

  # This binding is also used in fulfillment notes
  $(document).on 'click', 'button#fulfillments_back', ->
    line_item_id = $(this).data('line-item-id')
    data = line_item_id: line_item_id
    $.ajax
      type: 'GET'
      url: "/fulfillments"
      data: "line_item_id" : line_item_id

  # Fulfillment Bindings

  $(document).on 'click', '.otf_fulfillment_new', ->
    allowSubmit = true
    line_item_id = $(this).data('line-item-id')
    data = line_item_id: line_item_id
    $.ajax
      type: 'GET'
      url: "/fulfillments/new"
      data: data

  $(document).on 'click', '.otf-fulfillment-list', ->
    line_item_id = $(this).data('line-item-id')
    data = line_item_id: line_item_id
    $.ajax
      type: 'GET'
      url: "/fulfillments"
      data: "line_item_id" : line_item_id

  $(document).on 'click', '.otf_fulfillment_edit', ->
    allowSubmit = true
    row_index   = $(this).parents("tr").data("index")
    fulfillment_id = $(this).parents("#fulfillments-table").bootstrapTable("getData")[row_index].id
    $.ajax
      type: 'GET'
      url: "/fulfillments/#{fulfillment_id}/edit"

  $(document).on 'click', '.add_fulfillment', (e)->
    e.preventDefault()
    if allowSubmit
      $('.fulfillment-form').submit()
      allowSubmit = false
    else
      return false

  $(document).on 'click', '#date_fulfilled_field, #fulfillment_quantity', ->
    allowSubmit = true
