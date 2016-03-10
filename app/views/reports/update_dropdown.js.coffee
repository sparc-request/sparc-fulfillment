                     
$('#protocol_section').html('<%= escape_javascript(select_tag "protocol_ids", truncated_options_from_collection_for_select(@protocols, "id", "short_title_with_sparc_id"), multiple: true, "data-live-search" => true, "data-actions-box" => true, title: t(:reports)[:all_protocols], class: "selectpicker form-control") %>')
$('.dropdown-glyphicon.glyphicon.glyphicon-refresh.spin').remove()
$('.selectpicker').selectpicker('refresh')
