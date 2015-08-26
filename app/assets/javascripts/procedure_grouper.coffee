$ ->

  class ProcedureGrouper
    constructor: (@core) ->
      @rows = $(@core).find('tbody tr')

    duplicate_services: (rows = this.rows) ->
      service_ids = []

      map_service_ids = (row) ->
        service_ids.push $(row).data('service-id')

      detect_duplicates = (ids) ->
        duplicate_ids = []

        find_duplicate = (id) ->
          if _.indexOf(service_ids, id) != _.lastIndexOf(service_ids, id)
            duplicate_ids.push id

        find_duplicate id for id in _.uniq ids

        return _.uniq duplicate_ids

      map_service_ids row for row in rows

      return detect_duplicates(service_ids)

  window.ProcedureGrouper = ProcedureGrouper
