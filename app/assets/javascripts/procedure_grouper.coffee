$ ->

  class ProcedureGrouper
    constructor: (@core) ->
      @rows = $(@core).find('tbody tr.procedure')
      @procedures_table = $(@core).find('table.procedures tbody')

    find_rows: (group_id) ->
      $(this.procedures_table).find("tr.procedure[data-group-id='#{group_id}']")

    find_group: (group_id) ->
      $(this.procedures_table).find("tr.procedure-group[data-group-id='#{group_id}']")

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
      services = this.find_rows(group_id)
      title = $(services[0]).find('td.name').text()
      service_count = services.length

      this.procedures_table.prepend("<tr class='procedure-group' data-group-id='#{group_id}'><td colspan='8'><button type='button' class='btn btn-xs btn-primary'><span>#{service_count}</span><span class='glyphicon glyphicon-chevron-right'></span></button>#{title} #{service_billing_type}</td></tr>")

      return $(this.procedures_table).find('.procedure-group').first()

    add_service_to_group: (service_row, service_group) ->
      row = $(service_row).detach()

      $(service_group).after(row)

    remove_service_from_group: (service_row, service_group) ->
      row = $(service_row).detach()

      $(service_group).before(row)
      $(row).removeAttr('style')
      $(row).find('td.name').removeClass('muted')
      qty = $(service_group).find('span').first().text()
      $(service_group).find('span').first().text("#{parseInt(qty) - 1}")

    destroy_group: (group_id) ->
      this.find_group(group_id).remove()
      this.find_rows(group_id).removeAttr("style").find("td.name")

    show_group: (group_id) ->
      rows = this.find_rows(group_id)
      group = this.find_group(group_id)
      button_span = $(group).find('span.glyphicon')

      $(rows).slideDown()
      $(button_span).addClass('glyphicon-chevron-down').removeClass('glyphicon-chevron-right')

    hide_group: (group_id) ->
      rows = this.find_rows(group_id)
      group = this.find_group(group_id)
      button_span = $(group).find('span.glyphicon')

      $(rows).slideUp()
      $(button_span).addClass('glyphicon-chevron-right').removeClass('glyphicon-chevron-down')

    style_group: (service_group) ->
      $(service_group).css('border', '2px #333 solid')
      group_id   = $(service_group).data('group-id')
      group_rows = this.find_rows(group_id)
      $(group_rows).css('border-right', '2px #333 solid').css('border-left', '2px #333 solid')
      $(group_rows).find("td.name").addClass('muted')
      $(group_rows).last().css('border-bottom', '2px #333 solid')

    group_size: (group_id) ->
      this.find_rows(group_id).length

    update_group_membership: (row, original_group_id) ->
      group_id = $(row).data('group-id')
      service_group = this.find_group(group_id)
      self = this

      do_i_have_siblings = ->
        self.group_size(group_id) > 1

      does_my_group_exist = ->
        service_group.length >= 1

      join_group = ->
        self.add_service_to_group(row, service_group)

      create_a_group = ->
        self.create_group(group_id)

      wrangle_siblings = ->
        siblings = self.find_rows()

        self.add_service_to_group sibling, service_group for sibling in siblings

      go_to_pasture = ->
        self.remove_service_from_group(row, service_group)
        #attach somewhere in pasture

      i_left_a_group = ->
        group_id != original_group_id

      does_original_group_have_1_member = ->
        self.group_size(original_group_id) == 1

      destroy_a_group = ->
        self.destroy_group(original_group_id)

      if do_i_have_siblings()
        if does_my_group_exist()
          join_group()
        else
          create_a_group()
          join_group()
          wrangle_siblings()
      else
        go_to_pasture()

      if i_left_a_group() && does_original_group_have_1_member()
        destroy_a_group()

      # if this.group_size(group_id) == 1
      #   this.remove_service_from_group($(row), service_group)
      #   this.destroy_group(group_id)
      # else if service_group.length != 0 && service_group.data('group-id') == group_id
      #   add_service_to_group(row, service_group)


  fire = () ->
    for core in $('tr.core')
      pg = new ProcedureGrouper(core)

      for service in pg.duplicate_services()
        group = pg.create_group(service)
        rows = $("tr.procedure[data-group-id='#{service}']")

        add = (row, group) ->
          pg.add_service_to_group row, group

        add row, group for row in rows
        pg.style_group group
        pg.hide_group(service)

  window.fire = fire

  window.ProcedureGrouper = ProcedureGrouper
