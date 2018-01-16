$ ->
  $(document).on 'click', '.otf_fulfillment_delete', ->
    $.ajax
      type: 'delete'
      url: "/fulfillments/#{$(this).data('id')}.js"

