(exports ? this).dateSorter = (a, b) ->
  sort_a = new Date(a)
  sort_b = new Date(b)

  return 1 if sort_a > sort_b
  return -1 if sort_a < sort_b
  return 0

$ ->

  bs_tables = $("table[data-toggle='table']")

  $(document).on "all.bs.table", bs_tables, ->
    $(this).find('[data-toggle="tooltip"]').tooltip()

  $(document).on "sort.bs.table", bs_tables, ->
    setTimeout (->
      $('table [data-toggle="tooltip"]').tooltip()
    ), 2500

  $(document).on "load-success.bs.table", bs_tables, ->
    $(this).
      find(".th-inner.sortable i").
      remove()
    $(this).
      find(".th-inner.sortable").
      append("<i class='glyphicon glyphicon-sort opacity50'></i>")

  $.each bs_tables, (index, table) ->
    $(table).on "sort.bs.table", (e, name, order) ->
      $(this).
        find(".th-inner.sortable i").
        remove()
      $(this).
        find(".th-inner.sortable").
        append("<i class='glyphicon glyphicon-sort opacity50'></i>")
      $(this).
        find("th.#{name} i").
        toggleClass("glyphicon-sort")

      if order == "desc"
        $(this).
          find("th.#{name} i").
          toggleClass("glyphicon-sort glyphicon-sort-by-attributes-alt opacity50")
      else
        $(this).
          find("th.#{name} i").
          toggleClass("glyphicon-sort glyphicon-sort-by-attributes opacity50")
