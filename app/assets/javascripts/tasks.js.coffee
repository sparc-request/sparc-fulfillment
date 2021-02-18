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

  $('[data-toggle="tooltip"]').tooltip()

  $('#tasksList .export button').addClass('no-caret').siblings('.dropdown-menu').addClass('d-none')

  $(document).on 'click', '#tasksList .export button', ->
    url = new URL($('#tasks').data('url'), window.location.origin)
    url.pathname = url.pathname.replace('json', 'csv')
    window.location = url

  $(document).on 'click', 'table.tasks tbody td:not(td.complete, td.reschedule)', ->
    row_id  = $(this).parents("tr").attr("data-index")
    task_id = $(this).parents("table").bootstrapTable("getData")[row_id].id

    $.ajax
      type: 'GET'
      url: "/tasks/#{task_id}.js"

  $(document).on 'click', "input[type='checkbox'].complete", ->
    task_id = $(this).attr('task_id')
    checked = $(this).is(':checked')
    data    = 'task': 'complete' : checked

    $.ajax
      type: 'PUT'
      url: "/tasks/#{task_id}.js"
      data: data

  $(document).on "change", "#completeToggle, #allTasksToggle", ->
    scope = if $("#allTasksToggle").prop("checked") then "all" else "mine"
    status = if $("#completeToggle").prop("checked") then "complete" else "incomplete"

    $('#tasks').bootstrapTable('refresh', {url: "/tasks.json?scope=" + scope + "&status=" + status, silent: "true"})

