$("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>")
if "<%= @delete %>"
  remove_arm("<%= @arm.id %>")
