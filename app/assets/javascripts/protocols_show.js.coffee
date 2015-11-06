$ ->

  if $('body.protocols-show').length > 0

    # Bootstrap Tab persistence

    $('.protocol-tab > a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
      tab = String(e.target).split('#')[1]
      date = new Date()
      date.setTime(date.getTime() + (60 * 60 * 1000))
      $.cookie('active-protocol-tab', tab, expires: date, path: '/') # save tab to cookie

    # Study Schedule Report button

    $(document).on 'load-success.bs.table', 'table.protocol', ->
      tables_to_refresh = ['table.protocol_reports']

      remote_document_generator 'button.study_schedule_report', tables_to_refresh

    $(document).on 'click', 'a.attached_file', ->
      update_view_on_download_new_report $(this), 'table.protocol_reports', 'Protocol'
