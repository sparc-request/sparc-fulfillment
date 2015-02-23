$("#line_item_<%= @line_item.id %> .line_item_service_name").text("<%= @line_item.service.name %>")
$("#modal_place").modal 'hide'