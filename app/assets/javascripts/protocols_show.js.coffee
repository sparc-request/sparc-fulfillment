$ ->

  if $('body.protocols-show').length > 0

    # Bootstrap Tab persistence

    current_tab = $.cookie('active-protocol-tab')

    if current_tab && current_tab.length > 0
      $(".protocol-tab > a[href='##{current_tab}']").tab('show') # show tab on load

    $('.protocol-tab > a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
      tab = String(e.target).split('#')[1]
      $.cookie('active-protocol-tab', tab, expires: 1, path: '/') # save tab to cookie

    # Study Schedule Report button

    $(document).on 'load-success.bs.table', 'table.protocol', ->
      tables_to_refresh = ['table.protocol_reports']

      remote_document_generator 'a.study_schedule_report', tables_to_refresh

    $(document).on 'click', 'a.attached_file', ->
      update_view_on_download_new_report $(this), 'table.protocol_reports', 'Protocol'