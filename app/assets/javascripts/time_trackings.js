window.timeTrackingRowStyle = function(row, index) {
  if (row.is_active) {
    return { classes: 'table-warning' };
  }
  return {};
};

$(document).ready(function() {
  $(document).on('change', '#timeTrackingStartTime, #timeTrackingEndTime', function(event) {
    var startVal = $('#timeTrackingStartTime').val();
    var endVal = $('#timeTrackingEndTime').val();
    if (startVal && endVal) {
      var start = new Date("01/01/2000 " + startVal);
      var end = new Date("01/01/2000 " + endVal);
      var diffMs = end - start;
      if (diffMs < 0) { diffMs += 24 * 60 * 60 * 1000; }
      var diffHrs = diffMs / 1000 / 60 / 60;
      $('#timeTrackingQty').val(diffHrs.toFixed(2));
    }
  });

  $(document).on('keyup', '#sidebarSearch', function() {
    var query = $(this).val().toLowerCase();
    $('.tab-content .tree-node').each(function() {
      var text = $(this).text().toLowerCase();
      $(this).toggle(text.includes(query));
    });
  });

  // Sidebar Protocols open/closed accordion state persistence via cookies
  $(document).on('shown.bs.collapse', '#protocolsTree .collapse', function(e) {
    if (!$(e.target).is(this)) return; // ignore bubbled events

    if (this.id.includes('-collapse-protocol-')) {
      var protocolId = this.id.split('-collapse-protocol-')[1];
      var openProtocolIds = (Cookies.get('open_sidebar_protocols') || '').split(',').filter(Boolean);
      if (!openProtocolIds.includes(protocolId)) {
        openProtocolIds.push(protocolId);
        Cookies.set('open_sidebar_protocols', openProtocolIds.join(','), { path: '/' });
      }
    } else if (this.id.includes('-collapse-li-')) {
      var liId = this.id.split('-collapse-li-')[1];
      var openLiIds = (Cookies.get('open_sidebar_line_items') || '').split(',').filter(Boolean);
      if (!openLiIds.includes(liId)) {
        openLiIds.push(liId);
        Cookies.set('open_sidebar_line_items', openLiIds.join(','), { path: '/' });
      }
    }
  });

  $(document).on('hidden.bs.collapse', '#protocolsTree .collapse', function(e) {
    if (!$(e.target).is(this)) return;

    if (this.id.includes('-collapse-protocol-')) {
      var protocolId = this.id.split('-collapse-protocol-')[1];
      var openProtocolIds = (Cookies.get('open_sidebar_protocols') || '').split(',').filter(Boolean);
      openProtocolIds = openProtocolIds.filter(function(id) { return id !== protocolId; });
      Cookies.set('open_sidebar_protocols', openProtocolIds.join(','), { path: '/' });
    } else if (this.id.includes('-collapse-li-')) {
      var liId = this.id.split('-collapse-li-')[1];
      var openLiIds = (Cookies.get('open_sidebar_line_items') || '').split(',').filter(Boolean);
      openLiIds = openLiIds.filter(function(id) { return id !== liId; });
      Cookies.set('open_sidebar_line_items', openLiIds.join(','), { path: '/' });
    }
  });
});
