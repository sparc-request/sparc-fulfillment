(exports ? this).dateSorter = (a, b) ->
  sort_a = new Date(a)
  sort_b = new Date(b)
  
  return 1 if sort_a > sort_b
  return -1 if sort_a < sort_b
  return 0
