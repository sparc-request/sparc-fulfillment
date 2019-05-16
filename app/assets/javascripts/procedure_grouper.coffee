# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

$ ->

  class ProcedureGrouper

    constructor: () ->
      @cores = $('.core')

    find_rows: (group_id) ->
      $("tr.procedure[data-group-id='#{group_id}']")

    find_group: (group_id) ->
      $("tr.procedure-group[data-group-id='#{group_id}']")

    duplicate_group_ids: (rows) ->
      group_ids = []
      self      = this

      map_group_ids = (row) ->
        group_ids.push $(row).data('group-id')

      is_already_grouped = (group_id) ->
        self.find_group(group_id).length == 1

      detect_duplicates = (ids) ->
        duplicate_group_ids = []

        find_duplicate = (id) ->
          if _.indexOf(group_ids, id) != _.lastIndexOf(group_ids, id) && !is_already_grouped(id)
            duplicate_group_ids.push id

        find_duplicate id for id in _.uniq ids

        return _.uniq duplicate_group_ids

      map_group_ids row for row in rows

      return detect_duplicates(group_ids)

    create_group: (group_id) ->
      [service_billing_type, service_id] = group_id.split('_')
      rows              = this.find_rows(group_id)
      title             = $(rows[0]).find('td.name').text()
      row_count         = rows.length
      procedures_table  = $(rows).first().parents('.procedures tbody')

      $(procedures_table).prepend("<tr class='procedure-group' id='group-#{group_id}' data-group-id='#{group_id}'><td colspan='10'><button type='button' class='btn btn-xs btn-primary'><span class='count'>#{row_count}</span><span class='glyphicon glyphicon-chevron-right'></span></button>#{title} #{service_billing_type}</td></tr>")

      return this.find_group(group_id)

    redraw_group: (group_id) ->
      count = this.group_size(group_id)
      group = this.find_group(group_id)

      $(group).find('span.count').text(count)
      this.style_group(group)

    add_service_to_group: (service_row, service_group) ->
      row       = $(service_row).detach()
      group_id  = $(service_row).data('group-id')

      if !this.is_group_open(group_id)
        $(row).hide()

      $(service_group).after(row)

    remove_service_from_group: (service_row) ->
      procedures_table  = $(service_row).parents('.procedures tbody')
      row               = $(service_row).detach()

      $(procedures_table).append(row)
      $(row).removeAttr('style').find('td.name').removeClass('muted')

    destroy_group: (group_id) ->
      row = this.find_rows(group_id)

      this.remove_service_from_group(row)
      this.find_group(group_id).remove()

    show_group: (group_id) ->
      rows        = this.find_rows(group_id)
      group       = this.find_group(group_id)
      button_span = $(group).find('span.glyphicon')

      $(rows).slideDown()
      $(button_span).addClass('glyphicon-chevron-down').removeClass('glyphicon-chevron-right')

    is_group_open: (group_id) ->
      group = this.find_group(group_id)

      $(group).find('.glyphicon-chevron-down').length > 0

    hide_group: (group_id) ->
      rows        = this.find_rows(group_id)
      group       = this.find_group(group_id)
      button_span = $(group).find('span.glyphicon')

      $(rows).slideUp()
      $(button_span).addClass('glyphicon-chevron-right').removeClass('glyphicon-chevron-down')

    style_group: (group) ->
      group_id  = $(group).data('group-id')
      rows      = this.find_rows(group_id)

      $(group).css('border', '2px #888 solid')
      $(rows).css('border-right', '2px #888 solid').css('border-left', '2px #888 solid')
      $(rows).find('td.name').addClass('muted')
      $(rows).first().css('border-bottom', 'none')
      $(rows).last().css('border-bottom', '2px #888 solid')

    group_size: (group_id) ->
      this.find_rows(group_id).length

    build_core_multiselect_options: (core) ->
      option_data = []
      multiselect = $(core).find('select.core_multiselect')
      self        = this

      find_row_name = (group_id) ->
        row = self.find_rows(group_id).first()

        if self.find_group(group_id).length != 0
          name = self.find_group(group_id).find('td').text().split(/\s+/).join(' ')

        else
          quantity = 1
          service_name = $(row).find('td.name').text().trim()
          billing_type = group_id.split('_')[0]
          name = [quantity, service_name, billing_type].join(' ')

        option_data.push label: name, title: name, value: group_id

      group_ids = _.uniq $.map $(core).find('tr.procedure'), (row) ->
        $(row).data('group-id')

      find_row_name group_id for group_id in group_ids

      $(multiselect).multiselect('dataprovider', option_data)
      $(multiselect).multiselect('setOptions', includeSelectAllOption: true, numberDisplayed: 0, nonSelectedText: 'Select Services')
      $(multiselect).multiselect('rebuild')
      if $(multiselect).hasClass('disabled')
        $(multiselect).multiselect('disable')
      
  

    destroy_row: (row) ->
      group_id        = $(row).data('group-id')
      core            = $(row).parents('.core')
      group           = this.find_group(group_id)
      group_siblings_count  = this.group_size(group_id) - 1
      core_siblings_count  = $(core).find('tr.procedure').length - 1

      if core_siblings_count == 0
        $(core).remove()
      else
        if group_siblings_count == 1
          $(row).remove()
          this.destroy_group(group_id)
        else
          $(row).remove()
          this.redraw_group(group_id)
        this.build_core_multiselect_options(core)

    remove_all_new_row_classes: () ->
      $('tr.procedure.new_service').removeClass('new_service')

    update_group_membership: (row, original_group_id) ->
      group_id        = $(row).data('group-id')
      group           = this.find_group(group_id)
      original_group  = this.find_group(original_group_id)
      self            = this

      do_i_have_siblings = ->
        self.group_size(group_id) > 1

      does_my_group_exist = ->
        group.length == 1

      join_group = (group) ->
        self.add_service_to_group(row, group)
        self.redraw_group(group_id)
        self.redraw_group(original_group_id)

      create_a_group = ->
        self.create_group(group_id)

      wrangle_siblings = (group) ->
        group_id = $(group).data('group-id')
        siblings = self.find_rows(group_id)

        self.add_service_to_group sibling, group for sibling in siblings
        self.redraw_group(group_id)
        self.show_group(group_id)

      go_to_pasture = ->
        self.remove_service_from_group(row)
        self.redraw_group(original_group_id)

      i_left_a_group = ->
        group_id != original_group_id

      does_original_group_have_1_member = ->
        self.group_size(original_group_id) == 1

      destroy_a_group = ->
        self.destroy_group(original_group_id)

      i_am_a_new_row = (row) ->
        $(row).hasClass('new_service')

      if do_i_have_siblings()
        if does_my_group_exist()
          join_group(group)
        else
          group = create_a_group()
          join_group(group)
          wrangle_siblings(group)
      else
        if !i_am_a_new_row(row)
          go_to_pasture()

      if i_left_a_group() && does_original_group_have_1_member()
        destroy_a_group()

      self.remove_all_new_row_classes()
      self.build_core_multiselect_options($(row).parents('.core'))

    initialize_multiselect: (multiselect) ->
      $(multiselect).multiselect(includeSelectAllOption: true, numberDisplayed: 1, nonSelectedText: 'Please Select')

    initialize_multiselects: ->
      multiselects = $('select.core_multiselect')

      this.initialize_multiselect multiselect for multiselect in multiselects

    initialize: ->
      self = this

      self.initialize_multiselects()

      for core in this.cores
        rows = $(core).find('tr.procedure')

        for group_id in self.duplicate_group_ids(rows)
          group = self.create_group(group_id)
          rows  = self.find_rows(group_id)

          add = (row, group) ->
            self.add_service_to_group row, group

          add row, group for row in rows
          self.style_group group
          self.hide_group(group_id)

        self.build_core_multiselect_options(core)
        self.remove_all_new_row_classes()

  window.ProcedureGrouper = ProcedureGrouper
