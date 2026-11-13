// 'My Time Entries' tab //

// Highlight running timer
window.timeTrackingRowStyle = function(row, index) {
  if (row.is_active) {
    return { classes: 'table-warning' };
  }
  return {};
};

// Custom table sort to pin running timer on top
window.timeTrackingCustomSort = function(sortName, sortOrder, data) {
  // Multiply by -1 to reverse the sort order
  var order = sortOrder === 'desc' ? -1 : 1;

  // For date, quantity or srid, swap in raw values so sorting works
  var fieldMap = {
    'date': 'raw_date',
    'quantity': 'raw_quantity',
    'srid': 'raw_srid'
  };
  var field = fieldMap[sortName] || sortName;

  data.sort(function(a, b) {
    // Running timer always first
    if (a.is_active !== b.is_active) {
      return a.is_active ? -1 : 1;
    }

    // Remaining rows sorted by chosen column
    var valA = a[field] != null ? a[field] : '';
    var valB = b[field] != null ? b[field] : '';

    // Handle number sorting
    if (typeof valA === 'number' && typeof valB === 'number') {
      return (valA - valB) * order;
    }

    // Handle string sorting
    return String(valA).localeCompare(String(valB), undefined, { numeric: true }) * order;
  });
};

$(document).ready(function() {
  // Set qty and start/end times in the time tracking modal form
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

  // Hide/Show sidebar items based on search query
  $(document).on('keyup input', '#sidebarSearch', function() {
    var query = $(this).val().toLowerCase();
    $('#all-tab .protocol-node').each(function() {
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


  // 'Team Approval' tab //

  // Initialize datepickers in filter sidebar
  $('#filterDateFromPicker, #filterDateToPicker').datetimepicker({
    format: 'MM/DD/YYYY',
    useCurrent: false
  });

  // Enable/disable top action buttons based on table selections
  function updateTeamApprovalActionButtons() {
    var $table = $('#teamApprovalTable');
    if (!$table.length) return;

    var selections = $table.bootstrapTable('getSelections') || [];
    var count = selections.length;
    $('#selectedCount').text(count);

    var $startBtn = $('#startReviewBtn');
    var $finishBtn = $('#finishReviewBtn');
    var $importBtn = $('#importToFulfillmentsBtn');
    var $updatesBtn = $('#requestUpdatesBtn');

    if (count === 0) {
      $startBtn.prop('disabled', true);
      $finishBtn.prop('disabled', true);
      $importBtn.prop('disabled', true);
      $updatesBtn.prop('disabled', true);
      return;
    }

    var statuses = selections.map(function(row) { return row.status_name; });
    var allInProgress = statuses.every(function(s) { return s === 'In Progress'; });
    var allUnderReview = statuses.every(function(s) { return s === 'Under Review'; });
    var allReady = statuses.every(function(s) { return s === 'Ready for Import'; });

    $startBtn.prop('disabled', !allInProgress);
    $finishBtn.prop('disabled', !allUnderReview);
    $updatesBtn.prop('disabled', !allUnderReview);
    $importBtn.prop('disabled', !allReady);
  }

  // Recalculate top action button states after table events
  $(document).on(
    'check.bs.table uncheck.bs.table check-all.bs.table uncheck-all.bs.table load-success.bs.table', '#teamApprovalTable',
    function() {
      updateTeamApprovalActionButtons();
    }
  );

  // Update status of selected rows
  function updateSelectedStatus(newStatus) {
    var $table = $('#teamApprovalTable');
    var selections = $table.bootstrapTable('getSelections') || [];
    var ids = selections.map(function(row) { return row.id; });
    if (ids.length === 0) return;

    $.ajax({
      url: '/time_trackings/update_status',
      type: 'PUT',
      data: {
        ids: ids,
        status: newStatus
      },
      headers: {
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      },
      success: function() {
        $table.bootstrapTable('refresh');
        $('#timeTrackingsTable').bootstrapTable('refresh');
        updateTeamApprovalActionButtons();
      }
    });
  }

  // Top action button  handlers
  $(document).on('click', '#startReviewBtn', function() {
    updateSelectedStatus('Under Review');
  });

  $(document).on('click', '#finishReviewBtn', function() {
    updateSelectedStatus('Ready for Import');
  });

  $(document).on('click', '#requestUpdatesBtn', function() {
    updateSelectedStatus('In Progress');
  });

  // Create fulfillments from selected time entries
  $(document).on('click', '#importToFulfillmentsBtn', function() {
    var $table = $('#teamApprovalTable');
    var selections = $table.bootstrapTable('getSelections') || [];
    var ids = selections.map(function(row) { return row.id; });
    if (ids.length === 0) return;

    $.ajax({
      url: '/time_trackings/import_to_fulfillments',
      type: 'POST',
      data: { ids: ids },
      headers: {
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      },
      success: function() {
        $table.bootstrapTable('refresh');
        $('#timeTrackingsTable').bootstrapTable('refresh');
        updateTeamApprovalActionButtons();
      },
      error: function(xhr) {
        var msg = (xhr.responseJSON && xhr.responseJSON.error) || 'Failed to import entries.';
        Swal.fire({ title: 'Error', text: msg, icon: 'error' });
      }
    });
  });

  // Apply filters
  $(document).on('click', '#applyFiltersBtn', function() {
    var params = [];

    var staffId = $('#filterStaff').val();
    if (staffId) params.push('identity_id=' + encodeURIComponent(staffId));

    var protocolId = $('#filterProtocol').val();
    if (protocolId) params.push('protocol_id=' + encodeURIComponent(protocolId));

    var dateFrom = $('#filterDateFrom').val();
    if (dateFrom) params.push('date_from=' + encodeURIComponent(dateFrom));

    var dateTo = $('#filterDateTo').val();
    if (dateTo) params.push('date_to=' + encodeURIComponent(dateTo));

    $('.filter-status-checkbox:checked').each(function() {
      params.push('status[]=' + encodeURIComponent($(this).val()));
    });

    var url = '/time_trackings/team_approval.json';
    if (params.length > 0) {
      url += '?' + params.join('&');
    }

    $('#teamApprovalTable').bootstrapTable('refresh', { url: url});
  });

  // Clear filters
  $(document).on('click', '#clearFiltersBtn', function() {
    $('#filterStaff').val('').selectpicker('refresh');
    $('#filterProtocol').val('').selectpicker('refresh');
    $('#filterDateFrom').val('');
    $('#filterDateTo').val('');
    $('.filter-status-checkbox').each(function() {
      $(this).prop('checked', $(this).val() !== 'Imported');
    });

    $('#teamApprovalTable').bootstrapTable('refresh', { url: '/time_trackings/team_approval.json'});
  });

  // Refresh tables when switching between tabs
  $(document).on('shown.bs.tab', '#timeTrackingTabs a[data-toggle="tab"]', function(e) {
   if (e.target.id === 'myTimeEntriesTabLink') {
      $('#timeTrackingsTable').bootstrapTable('refresh');
    } else if (e.target.id === 'teamApprovalTabLink') {
      $('#teamApprovalTable').bootstrapTable('refresh');
      updateTeamApprovalActionButtons();
    }
  });
});
