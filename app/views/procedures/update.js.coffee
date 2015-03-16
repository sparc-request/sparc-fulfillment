<% if @note.present? %>
  $("#modal_area").html("<%= escape_javascript(render(partial: 'notes/new', locals: { note: @note })) %>")
  $("#modal_place").modal 'show'
  $(".modal-content").find(":input").not("[type='hidden'],[type='button']").first().focus()
<% else %>
  $(".row.procedure[data-id='<%= @procedure.id %>'] .followup .text-center").empty()
  $(".row.procedure[data-id='<%= @procedure.id %>'] .followup .text-center").html("<%= escape_javascript(render(partial: 'appointments/followup_calendar', locals: { procedure: @procedure })) %>")
  $(".row.procedure[data-id='<%= @procedure.id %>'] .date").datetimepicker(format: 'YYYY-MM-DD', defaultDate: "<%= format_date(@procedure.follow_up_date) %>")
  $("#modal_place").modal 'hide'
<% end %>
