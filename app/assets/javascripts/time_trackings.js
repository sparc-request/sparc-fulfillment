$(document).ready(function() {
  $(document).on('change', '#timeTrackingStartTime, #timeTrackingEndTime', function(event) {
    var startVal = $('#timeTrackingStartTime').val();
    var endVal = $('#timeTrackingEndTime').val();
    if(startVal && endVal) {
      var start = new Date("01/01/2000 " + startVal);
      var end = new Date("01/01/2000 " + endVal);
      var diffMs = end - start;
      if (diffMs < 0) { diffMs += 24 * 60 * 60 * 1000; }
      var diffHrs = diffMs / 1000 / 60 / 60;
      $('#timeTrackingQty').val(diffHrs.toFixed(2));
    }
  });
});
