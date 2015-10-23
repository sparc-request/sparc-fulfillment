(exports ? this).dateSorter = (a, b) ->
  sort_a = new Date(a)
  sort_b = new Date(b)

  if sort_a > sort_b then -1 else 1

pastDueDateCleaner = (a) ->
  return a.replace(" - PAST DUE", "").replace("<span class=\"overdue-task\">", "").replace("</span>", "")
