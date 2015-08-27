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

      this.procedures_table.prepend("<tr class='procedure-group'><td colspan='8' class='text-left'>#{title} (#{service_count}) #{service_billing_type}</td></tr>")

  window.ProcedureGrouper = ProcedureGrouper
