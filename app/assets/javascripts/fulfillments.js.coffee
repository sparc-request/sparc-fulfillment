# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

$(document).on 'hide.datetimepicker', '.fulfillment-invoiced-date-datepicker', ->
  new_invoiced_date = $(this).datetimepicker('date').format('MM/DD/YYYY')
  initial_invoiced_date = $(this).find('input').data('initial-invoiced-date')
  if new_invoiced_date == initial_invoiced_date
    return
  Rails.fire($(this).parents('form')[0], 'submit')

$(document).on 'click', '.otf-fulfillment-delete', ->
  proceed = confirm "Are you sure you want to delete this fulfillment?"
  if proceed
    $.ajax
      type: 'delete'
      url: "/fulfillments/#{$(this).data('fulfillment_id')}.js"

$(document).on 'click', '.fulfillment_documents', ->
    id = $(this).data('documentable-id')
    type = $(this).data('documentable-type')
    data  = document:
              documentable_id: id,
              documentable_type: type
    $.ajax
      type: 'GET'
      url: '/documents.js'
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
