$table = $('#documents_table')

getOrder = ->
  if $table.bootstrapTable('getOptions').sortOrder == 'asc' then -1 else 1

(exports ? this).dateSorter = (a, b) ->
  return -1 * getOrder() if !a
  return 1 * getOrder() if !b

  sort_a = new Date(a)
  sort_b = new Date(b)

  return 1 if sort_a > sort_b
  return -1 if sort_a < sort_b
  return 0

(exports ? this).dueDateSorter = (a, b) ->
  sort_a = new Date(pastDueDateCleaner(a))
  sort_b = new Date(pastDueDateCleaner(b))

  return 1 if sort_a > sort_b
  return -1 if sort_a < sort_b
  return 0

pastDueDateCleaner = (a) ->
  return a.replace(" - PAST DUE", "").replace("<span class=\"overdue-task\">", "").replace("</span>", "")

(exports ? this).fulfillmentDateSorter = (a, b) ->
  sort_a = new Date(fulfillmentDateCleaner(a))
  sort_b = new Date(fulfillmentDateCleaner(b))

  return 1 if sort_a > sort_b
  return -1 if sort_a < sort_b
  return 0

fulfillmentDateCleaner = (a) ->
  return a.replace('<span class="fulfillment_date_for_klok_entry">', '').replace('</span><i class="glyphicon glyphicon-time"></i>', '')
