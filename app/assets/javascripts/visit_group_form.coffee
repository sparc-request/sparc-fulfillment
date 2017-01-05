$ ->
  $('#modal_place').on 'shown.bs.modal', ->
    $('.add-visit').prop('disabled', true)
    $(document).on 'change', '.visit-group-position', ->
      unless $('.visit-group-position option:selected').text() == ''
        $('.add-visit').prop('disabled', false)
      else
        $('.add-visit').prop('disabled', true)

