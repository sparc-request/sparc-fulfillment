$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$("#modal_place").modal 'hide'
edit_arm("<%= @arm.name %>", "<%= @arm.id %>");
$("#arm-name-display-<%= @arm.id %>").html("<%= @arm.name %>");

