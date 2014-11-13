$(document).ready ->
  $('#participant_list').hide()
  $('#participant_tracker').hide()
  $('#study_level_charges').hide()
  $('#audit_reporting').hide()

$(document).on('click', '#study_schedule_tab', ->
  $('#participant_list').hide()
  $('#participant_tracker').hide()
  $('#study_level_charges').hide()
  $('#audit_reporting').hide()

  $('#participant_list_tab').attr('class','')
  $('#participant_tracker_tab').attr('class','')
  $('#study_level_charges_tab').attr('class','')
  $('#audit_reporting_tab').attr('class','')

  $('#study_schedule').show()
  $('#study_schedule_tab').attr('class','active')
  )

$(document).on('click', '#participant_list_tab', ->
  $('#study_schedule').hide()
  $('#participant_tracker').hide()
  $('#study_level_charges').hide()
  $('#audit_reporting').hide()

  $('#study_schedule_tab').attr('class','')
  $('#participant_tracker_tab').attr('class','')
  $('#study_level_charges_tab').attr('class','')
  $('#audit_reporting_tab').attr('class','')

  $('#participant_list').show()
  $('#participant_list_tab').attr('class','active')
  )

$(document).on('click', '#participant_tracker_tab', ->
  $('#study_schedule').hide()
  $('#participant_list').hide()
  $('#study_level_charges').hide()
  $('#audit_reporting').hide()

  $('#study_schedule_tab').attr('class','')
  $('#participant_list_tab').attr('class','')
  $('#study_level_charges_tab').attr('class','')
  $('#audit_reporting_tab').attr('class','')

  $('#participant_tracker').show()
  $('#participant_tracker_tab').attr('class','active')
  )

$(document).on('click', '#study_level_charges_tab', ->
  $('#study_schedule').hide()
  $('#participant_list').hide()
  $('#participant_tracker').hide()
  $('#audit_reporting').hide()

  $('#study_schedule_tab').attr('class','')
  $('#participant_list_tab').attr('class','')
  $('#participant_tracker_tab').attr('class','')
  $('#audit_reporting_tab').attr('class','')

  $('#study_level_charges').show()
  $('#study_level_charges_tab').attr('class','active')
  )

$(document).on('click', '#audit_reporting_tab', ->
  $('#study_schedule').hide()
  $('#participant_list').hide()
  $('#participant_tracker').hide()
  $('#study_level_charges').hide()

  $('#study_schedule_tab').attr('class','')
  $('#participant_list_tab').attr('class','')
  $('#participant_tracker_tab').attr('class','')
  $('#study_level_charges_tab').attr('class','')

  $('#audit_reporting').show()
  $('#audit_reporting_tab').attr('class','active')
  )