<% unless @errors.present? %>
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
$("#study-level-activities-table").bootstrapTable('refresh')
$("#modal_place").modal 'hide'
<% else %>
$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% end %>