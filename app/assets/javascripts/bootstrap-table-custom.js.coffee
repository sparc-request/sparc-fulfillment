(exports ? this).dateSorter = (a, b) ->
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
