class TimeTrackingsController < ApplicationController
  before_action { @highlighted_link = 'time_trackings' }

  def index
    # cwf Protocol has sparc sub_service_request_id. ssr has organization_id. The .protocols method grabs all the user's super_user orgs (including all children) and clinical_providers orgs and returns all protocols linked to the sub_service_requests of those organizations records.
    protocols_data = current_identity.protocols.pluck(:id, :sparc_id) # [[id, sparc_id], [id, sparc_id]]
    sparc_titles = Sparc::Protocol.where(id: protocols_data.map(&:last).compact.uniq).pluck(:id, :short_title).to_h # {sparc_id => "Short title", sparc_id => "Short title"}
    @available_protocols = protocols_data.map do |protocol_id, sparc_id|
      title = sparc_titles[sparc_id].presence || "Protocol #{protocol_id}"
      [title.truncate(90), protocol_id] # create [label, value] pairs for options_for_select helper
    end.sort_by(&:first)

    @sidebar_protocols = Protocol.where(id: current_identity.time_tracking_protocols.pluck(:protocol_id))
                                 .includes(:sub_service_request, :sparc_protocol, :pi, line_items: [:service, :components])

    @time_trackings = TimeTracking.where(identity_id: current_identity.id)
                                  .includes(
                                    protocol: [:sparc_protocol, :sub_service_request, :pi],
                                    line_item: :service,
                                    component: []
                                  )
                                  .order(date: :desc, started_at: :desc)
  end

  def create
    @time_tracking = TimeTracking.new(time_tracking_params)
    @time_tracking.identity_id = current_identity.id
    @time_tracking.date = Date.today
    @time_tracking.started_at = Time.current

    if @time_tracking.line_item_id.present?
      protocol = Protocol.find_by(id: @time_tracking.protocol_id)
      @time_tracking.sub_service_request_id = protocol.sub_service_request_id if protocol
    end

    @time_tracking.save

    respond_to do |format|
      format.js
      format.html { redirect_to time_trackings_path }
    end
  end

  def edit
    @time_tracking = TimeTracking.find(params[:id])

    respond_to do |format|
      format.js
    end
  end

  def stop
    @time_tracking = TimeTracking.find(params[:id])
    now = Time.current
    diff_hours = (now - @time_tracking.started_at) / 3600.0
    @time_tracking.update(ended_at: now, quantity: diff_hours.round(2))

    respond_to do |format|
      format.js
    end
  end

  def update
    @time_tracking = TimeTracking.find(params[:id])
    @time_tracking.update(
      date: time_tracking_params[:date],
      started_at: time_tracking_params[:started_at],
      ended_at: time_tracking_params[:ended_at],
      notes: time_tracking_params[:notes]
    )

    if @time_tracking.started_at && @time_tracking.ended_at
      diff_hours = (@time_tracking.ended_at - @time_tracking.started_at) / 3600.0
      @time_tracking.update(quantity: diff_hours.round(2))
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @time_tracking = TimeTracking.find(params[:id])
    @time_tracking.destroy

    respond_to do |format|
      format.js
    end
  end

  def update_sidebar
    current_identity.time_tracking_protocols.destroy_all

    if params[:protocol_ids].present?
      params[:protocol_ids].each do |protocol_id|
        current_identity.time_tracking_protocols.create(protocol_id: protocol_id)
      end
    end

    redirect_to time_trackings_path, notice: "Sidebar protocols updated"
  end

  private

  def time_tracking_params
    params.require(:time_tracking).permit(
      :protocol_id,
      :line_item_id,
      :component_id,
      :date,
      :started_at,
      :ended_at,
      :quantity,
      :notes
    )
  end
end
