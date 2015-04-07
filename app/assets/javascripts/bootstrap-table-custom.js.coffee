(exports ? this).dateSorter = (a, b) ->
  sort_a = a.substr(6,4) + a.substr(3,2) + a.substr(0,2) 
  sort_b = b.substr(6,4) + b.substr(3,2) + b.substr(0,2) 

  return 1 if sort_a > sort_b
  return -1 if sort_a < sort_b
  return 0
