$(document).ready ->
  $('.protocol_tab_panel').hide()
  $('.protocol_tab_panel#study_schedule').show()
  $('.protocol_tab').attr('class', 'protocol_tab')
  $('.protocol_tab#study_schedule').attr('class','active protocol_tab')

$(document).on('click', '.protocol_tab', ->
  $('.protocol_tab_panel').hide()
  $('.protocol_tab').attr('class', 'protocol_tab')
  id = $(this).attr('id')
  $(".protocol_tab_panel#"+id).show()
  $(this).attr('class', 'active protocol_tab')
  )