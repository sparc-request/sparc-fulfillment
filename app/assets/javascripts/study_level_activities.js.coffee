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

$ ->

  # Line Item Bindings

  $(document).on 'change', 'input.invoice_toggle', ->
    invoiced = $(this).prop('checked')
    fulfillment_id = $(this).data('id')
    $.ajax
      type: 'PUT'
      url: "/fulfillments/toggle_invoiced/#{fulfillment_id}"
      data:
        fulfillment:
          invoiced: invoiced

  $(document).on 'change', 'input.credit_toggle', ->
    credited = $(this).prop('checked')
    fulfillment_id = $(this).data('id')
    $.ajax
      type: 'PUT'
      url: "/fulfillments/toggle_credit/#{fulfillment_id}"
      data:
        fulfillment:
          credited: credited

  # This binding is also used in fulfillment notes
  $(document).on 'click', 'button#fulfillments_back', ->
    line_item_id = $(this).data('line-item-id')
    data = line_item_id: line_item_id
    $.ajax
      type: 'GET'
      url: "/fulfillments"
      data: "line_item_id" : line_item_id

  $(document).on 'click', 'button#edit_invoiced_date', ->
    line_item_id = $(this).data('line-item-id')
    data = line_item_id: line_item_id
    id = $(this).data('fulfillment_id')
    fulfillment_id = $(this).data('fulfillment_id')
    invoiced_date = $(this).data('fulfillment_invoiced_date')
    $.ajax
      type: 'PATCH'
      url: "/fulfillments/edit_invoiced_date/#{$(this).data('id')}"
      data:
        "line_item_id" : line_item_id
        fulfillment:
          id: fulfillment_id
          line_item_id: line_item_id
          invoiced_date: invoiced_date

  $(document).on 'click', '.edit-invoiced-date', ->
    console.log("sla")
    line_item_id = $(this).data('line-item-id')
    fulfillment_id = $(this).data('fulfillment_id')
    data = fulfillment:
      id: fulfillment_id
    $.ajax
      type: 'PATCH'
      url: "/fulfillments/edit_invoiced_date/#{$(this).data('fulfillment_id')}"
      data: data


  # Fulfillment Bindings

  $(document).on 'click', '.otf-fulfillment-edit', ->
    fulfillment_id = $(this).data('fulfillment_id')
    $.ajax
      type: 'GET'
      url: "/fulfillments/#{fulfillment_id}/edit"

  $(document).on 'click', 'fulfillment-invoiced-date', ->
    fulfillment_id = $(this).data('fulfillment_id')
    $.ajax
      type: 'GET'
      url: "/fulfillments/invoiced_date/#{fulfillment_id}"
      data:
        fulfillment:
          invoiced_date: invoiced_date




