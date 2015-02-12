$("#procedure_<%= @procedure_id %>").remove()

core = $("#core_<%= @core_id %>")
if core.next().attr('id') == "end_of_core_<%= @core_id %>"
  core.remove()
