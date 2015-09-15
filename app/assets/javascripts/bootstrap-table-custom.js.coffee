(exports ? this).dateSorter = (a, b) ->
  sort_a = new Date(a)
  sort_b = new Date(b)

  return 1 if sort_a > sort_b
  return -1 if sort_a < sort_b
  return 0

(exports ? this).dueDateSorter = (a, b) ->
  sort_a = new Date(dateCleaner(a))
  sort_b = new Date(dateCleaner(b))

  return 1 if sort_a > sort_b
  return -1 if sort_a < sort_b
  return 0

dateCleaner = (a) ->
  a = a.replace(" - PAST DUE", "")
  a = a.replace("<span class=\"overdue-task\">", '')
  a = a.replace("</span>", '')
  return a