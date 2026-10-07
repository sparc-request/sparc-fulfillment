$("#protocolsTree").html("<%= j render 'protocols_tree', sidebar_items: @sidebar_items, time_trackings: @time_trackings %>")

$("#protocol_ids").selectpicker('val', <%= current_identity.time_tracking_protocols.pluck(:protocol_id).map(&:to_s).to_json.html_safe %>)

NProgress.done()
