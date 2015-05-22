$("#visit_group_position").empty()
$("#visit_group_position").html("<%= escape_javascript (options_from_collection_for_select @visit_groups, 'position', 'insertion_name')%>")
$("#visit_group_position").prepend("<option value='', selected = 'add as last'>add as last</option>")

