$ ->
  $('#modal_place').on 'shown.bs.modal', ->
    $('.add-visit').prop('disabled', true)
    $('.add-visit-wrapper').tooltip()
    $(document).on 'change', '.visit-group-position', ->
      unless $('.visit-group-position option:selected').text() == ''
        $('.add-visit').prop('disabled', false)
        $('.add-visit-wrapper').tooltip('disable')
      else
        $('.add-visit').prop('disabled', true)
        $('.add-visit-wrapper').tooltip('enable')
