$('#protocol_section').html('<%= escape_javascript(select_tag "protocol_ids", truncated_options_from_collection_for_select(@protocols, "id", "short_title_with_sparc_id"), multiple: true, selectAll: true, id: "protocol_select", "data-live-search" => true, "data-actions-box" => true, title: t(:reports)[:all_protocols], class: "form-control") %>')
$('#protocol_select').multiselect({
  includeSelectAllOption: true,
  allSelectedText: "All Protocols",
  enableFiltering: true
})

$("#protocol_select").multiselect('selectAll', false)
$("#protocol_select").multiselect('updateButtonText')

$('.dropdown-glyphicon.glyphicon.glyphicon-refresh.spin').remove()

