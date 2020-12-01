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

$("#modalContainer").
  html("<%= j render 'study_level_activities/fulfillments_table', line_item: @line_item, header_text: 'Fulfillments List' %>").
  modal('show')

$('.fulfillments-list li').find("[data-field='docs']").closest('li').hide()
$('.fulfillments-list li').find("[data-field='notes']").closest('li').hide()
$('.fulfillments-list li').find("[data-field='export_invoiced']").closest('li').hide()
exclude_from_export('fulfillments-table')

$('#fulfillments-table').on 'load-success.bs.table', () ->
  $('input.invoice_toggle').bootstrapToggle()
  $('input.credit_toggle').bootstrapToggle()

$('#fulfillments-table').on 'column-switch.bs.table', (e, field, checked) ->
  if field == 'invoiced' && checked == true
    $('input.invoice_toggle').bootstrapToggle()
  if field == 'credited' && checked == true
    $('input.credit_toggle').bootstrapToggle()

$('.fulfillments-list .table-responsive').on 'show.bs.dropdown', ->
	$('.table-responsive').css 'overflow', 'inherit'

$('.fulfillments-list .table-responsive').on 'hide.bs.dropdown', ->
	$('.table-responsive').css 'overflow', 'auto'
