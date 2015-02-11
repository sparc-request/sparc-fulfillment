$("#flashes_container").html("<%= escape_javascript(render('flash')) %>")
if "<%= @delete %>"
  remove_arm("<%= @arm.id %>")
