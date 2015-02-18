$("#line_item_<%= @line_item.id %> .line_item_service_name").text("<%= @line_item.service.name %>")
$("#change_service_modal").modal 'hide'