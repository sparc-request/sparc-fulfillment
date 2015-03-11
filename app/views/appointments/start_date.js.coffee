$('#start_date').val("<%= @appointment.start_date %>")

start_input_div = $('.start_date_input')
start_btn_div = $('.start_date_btn')
if start_input_div.hasClass('hidden')
  start_btn_div.addClass('hidden')
  start_input_div.removeClass('hidden')

complete_btn = $('.complete_visit')
if complete_btn.hasClass('disabled')
  complete_btn.removeClass('disabled')