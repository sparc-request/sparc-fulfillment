$("#flashes_container").html("<%= escape_javascript(render(:partial =>'application/flash')) %>")
if "<%= @delete %>"
  remove_arm("<%= @arm.id %>")
