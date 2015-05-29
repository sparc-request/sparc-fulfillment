$("#flashes_container").html("<%= escape_javascript(render('application/flash')) %>")
if "<%= @delete %>"
  remove_arm("<%= @arm.id %>")
