$("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>");
console.log "<%= @delete %>"
if "<%= @delete %>"
  change_arm();
