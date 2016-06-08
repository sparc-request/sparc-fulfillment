$("#modal_area").html("<%= escape_javascript(render(:partial =>'participants/participant_form', locals: {protocol: @protocol, participant: @participant, header_text: 'Edit Participant'})) %>")
$("#modal_place").modal 'show'
$("#dob_time_picker").datetimepicker
  format: 'MM/DD/YYYY'
  ignoreReadonly: true
  viewMode: 'years'
$(".selectpicker").selectpicker()

