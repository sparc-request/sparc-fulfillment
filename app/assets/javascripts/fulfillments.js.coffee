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

$(document).on 'click', '.otf-fulfillment-delete', ->
  proceed = confirm "Are you sure you want to delete this fulfillment?"
  if proceed
    $.ajax
      type: 'delete'
      url: "/fulfillments/#{$(this).data('fulfillment_id')}.js"

$(document).on 'click', '.fulfillment_documents', ->
    console.log('Clicked')
    id = $(this).data('documentable-id')
    type = $(this).data('documentable-type')
    data  = document:
              documentable_id: id,
              documentable_type: type
    $.ajax
      type: 'GET'
      url: '/documents.js'
      data: data

$(document).on 'click', '.fulfillment-invoiced-date-edit', ->
  unless $(this).hasClass('disabled')
    $.ajax
      type: 'GET'
      url: "/fulfillments/invoiced_date_edit/#{$(this).data('fulfillment_id')}"

$(document).on 'click', '.invoiced-date-update', ->
    console.log("save clicked")
    fulfillment_id = $(this).data('fulfillment_id')
    id = $(this).data('id')
    invioced_date = $(this).data("invoiced_date")
    data = fulfillment:
      fulfillment_id: fulfillment_id

    $.ajax
      type: 'PATCH'
      url: "/fulfillments/invoiced_date_update/#{fulfillment_id}.js"
      data: data

$(document).on 'click', '.fulfillment_notes',  ->
    unless $(this).hasClass('disabled')
      id = $(this).data('notable-id')
      type = $(this).data('notable-type')
      data = note:
          notable_id: id,
          notable_type: type
      $.ajax
        type: 'GET'
        url: '/notes.js'
        data: data

 $(document).on 'click', 'button#invoiced_date_update', ->
    line_item_id = $(this).data('line-item-id')
    data = line_item_id: line_item_id
    id = $(this).data('id')
    fulfillment_id = $(this).data('id')
    invoiced_date = $(this).data('invoiced_date')
    $.ajax
      type: 'PATCH'
      url: "/fulfillments/invoiced_date_update/#{id}"
      data:
        "line_item_id" : line_item_id
        fulfillment:
          id: fulfillment_id
          line_item_id: line_item_id
          invoiced_date: $(this).data('invoiced_date')
        id: id
        invoiced_date: $(this).data('invoiced_date')

