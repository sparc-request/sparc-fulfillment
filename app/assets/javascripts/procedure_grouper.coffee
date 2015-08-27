$ ->

  class ProcedureGrouper
    constructor: (@core) ->
      @rows = $(@core).find('tbody tr.procedure')
      @procedures_table = $(@core).find('table.procedures tbody')

    duplicate_services: (rows = this.rows) ->
      service_ids = []

      map_service_ids = (row) ->
        service_ids.push $(row).data('group-id')

      detect_duplicates = (ids) ->
        duplicate_ids = []

        find_duplicate = (id) ->
          if _.indexOf(service_ids, id) != _.lastIndexOf(service_ids, id)
            duplicate_ids.push id

        find_duplicate id for id in _.uniq ids

        return _.uniq duplicate_ids

      map_service_ids row for row in rows

      return detect_duplicates(service_ids)

    create_group: (group_id) ->
      [service_billing_type, service_id] = group_id.split('_')
      services = $(this.procedures_table).find("tr[data-group-id='#{group_id}']")
      title = $(services[0]).find('td.name').text()
      service_count = services.length

      this.procedures_table.prepend("<tr class='procedure-group'><td colspan='8'><button type='button', class='btn btn-xs btn-primary'>#{service_count}<span class='glyphicon glyphicon-chevron-right'></span></button>#{title} #{service_billing_type}</td></tr>")

      return $(this.procedures_table).find('.procedure-group').first()

    add_service_to_group: (service_row, service_group) ->
      row = $(service_row).detach()

      $(service_group).after(row)
      $(service_group).css('border', '2px #333 solid')
      $(service_row).css('border-right', '2px #333 solid').css('border-left', '2px #333 solid')
      $(service_row).find('td.name').addClass('muted')

    show_group: (group_id) ->
      rows = $("tr.procedure[data-group-id=#{group_id}]")

      $(rows).slideDown('slow')

    hide_group: (group_id) ->
      rows = $("tr.procedure[data-group-id=#{group_id}]")

      $(rows).slideUp('slow')

  fire = () ->
    for core in $('tr.core')
      pg = new ProcedureGrouper(core)

      for service in pg.duplicate_services()
        group = pg.create_group(service)
        rows = $("tr.procedure[data-group-id='#{service}']")
        $(rows).first().css('border-bottom', '2px #333 solid')

        add = (row, group) ->
          pg.add_service_to_group row, group

        add row, group for row in rows
        pg.hide_group(service)

  window.fire = fire

  window.ProcedureGrouper = ProcedureGrouper
