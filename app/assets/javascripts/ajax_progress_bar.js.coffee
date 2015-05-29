$(document).ajaxStart ->
  NProgress.start()
  return

$(document).ajaxComplete ->
  NProgress.done()
  return
