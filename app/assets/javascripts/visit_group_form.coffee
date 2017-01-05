$ ->
  $('#modal_place').on 'shown.bs.modal', ->
    $('.add-visit').prop('disabled', true)
    $('.add-visit').attr('data-toggle', 'tooltip')
    $('.add-visit').prop('title', 'You must select a position')
    $(document).on 'change', '.visit-group-position', ->
      unless $('.visit-group-position option:selected').text() == ''
        $('.add-visit').prop('disabled', false)
        $('.add-visit').removeAttr('data-toggle')
        $('.add-visit').removeAttr('title')
      else
        $('.add-visit').prop('disabled', true)
        $('.add-visit').attr('data-toggle', 'tooltip')
        $('.add-visit').prop('title', 'You must select a position')
