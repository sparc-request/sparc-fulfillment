$ ->
  window.setTimeout (->
    $(".alert-dismissable").fadeTo(500, 0).slideUp 500, ->
      $(this).remove()
      return

    return
  ), 4000
