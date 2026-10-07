class TimeTrackingsController < ApplicationController
  before_action { @highlighted_link = 'time_trackings' }

  def index
    respond_to do |format|
      format.html do
        load_sidebar_data
      end

      format.json do
        @working_titles = current_identity.time_tracking_protocols.pluck(:protocol_id, :working_title).to_h
        @time_trackings = TimeTracking.where(identity_id: current_identity.id)
          .includes(protocol: [:sparc_protocol, :sub_service_request, :pi], line_item: :service)
          .order(date: :desc, started_at: :desc)
      end
    end
  end

  def create
    # 1) Stop any currently running timers for this user
    @stopped_timers = TimeTracking.stop_active_for(current_identity)

    # 2) Start new timer
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
    @time_tracking.stop

    respond_to do |format|
      format.js
    end
  end

  def update
    @time_tracking = TimeTracking.find(params[:id])

    date_str = time_tracking_params[:date]
    start_str = time_tracking_params[:started_at]
    end_str = time_tracking_params[:ended_at]

    parsed_date = Date.strptime(date_str, '%m/%d/%Y') rescue nil

    if parsed_date && start_str.present?
      started_at = Time.zone.parse("#{parsed_date} #{start_str}") rescue nil
    end

    if parsed_date && end_str.present?
      ended_at = Time.zone.parse("#{parsed_date} #{end_str}") rescue nil
    end

    if started_at && ended_at
      ended_at += 1.day if ended_at < started_at
      diff_hours = ((ended_at - started_at) / 3600.0).round(2)
    end

    @time_tracking.update(
      date: parsed_date || date_str,
      started_at: started_at || time_tracking_params[:started_at],
      ended_at: ended_at || time_tracking_params[:ended_at],
      quantity: diff_hours || time_tracking_params[:quantity],
      component_name: time_tracking_params[:component_name],
      notes: time_tracking_params[:notes]
    )

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
    selected = (params[:protocol_ids] || []).map(&:to_i)
    existing = current_identity.time_tracking_protocols.pluck(:protocol_id)

    current_identity.time_tracking_protocols.where.not(protocol_id: selected).destroy_all

    (selected - existing).each do |protocol_id|
      current_identity.time_tracking_protocols.create(protocol_id: protocol_id)
    end

    redirect_to time_trackings_path, notice: "Sidebar protocols updated"
  end

  def edit_protocol_title
    @protocol = Protocol.find(params[:protocol_id])
    @time_tracking_protocol = current_identity.time_tracking_protocols.find_or_initialize_by(protocol_id: @protocol.id)
    respond_to do |format|
      format.js
    end
  end

  def update_protocol_title
    @time_tracking_protocol = current_identity.time_tracking_protocols.find_or_initialize_by(protocol_id: params[:protocol_id])
    @time_tracking_protocol.update(working_title: params[:working_title])

    load_sidebar_data

    respond_to do |format|
      format.js
    end
  end

  def toggle_favorite_protocol
    @time_tracking_protocol = current_identity.time_tracking_protocols.find_by(protocol_id: params[:protocol_id])
    @time_tracking_protocol&.toggle!(:favorite)

    load_sidebar_data

    respond_to do |format|
      format.js
    end
  end

  def remove_protocol
    @time_tracking_protocol = current_identity.time_tracking_protocols.find_by(protocol_id: params[:protocol_id])
    @time_tracking_protocol&.destroy

    load_sidebar_data

    respond_to do |format|
      format.js
      format.html { redirect_to time_trackings_path }
    end
  end

def add_protocol_modal
  protocols_data = current_identity.protocols
    .joins(:sub_service_request, :sparc_protocol)
    .pluck(
      Protocol.arel_table[:id],
      Protocol.arel_table[:sparc_id],
      SubServiceRequest.arel_table[:ssr_id],
      Sparc::Protocol.arel_table[:short_title]
    )

  @available_protocols = protocols_data.map do |id, sparc_id, ssr_id, short_title|
    ["(#{sparc_id}-#{ssr_id}) #{short_title}".truncate(90), id]
  end.sort_by(&:first)

  @selected_protocol_ids = current_identity.time_tracking_protocols.pluck(:protocol_id)

  respond_to do |format|
    format.js
    format.html { redirect_to time_trackings_path }
  end
end


  private

  def load_sidebar_data
    @sidebar_items = current_identity.time_tracking_protocols
      .joins(:protocol)
      .includes(protocol: [:sub_service_request, :sparc_protocol, :pi, line_items: :service])
      .sort_by { |item| [item.protocol.sparc_id.to_i, item.protocol.sub_service_request&.ssr_id.to_i] }

    @open_protocol_ids  = cookies[:open_sidebar_protocols].to_s.split(',').map(&:to_i)
    @open_line_item_ids = cookies[:open_sidebar_line_items].to_s.split(',').map(&:to_i)
    @time_trackings = TimeTracking.where(identity_id: current_identity.id, ended_at: nil)

    @working_titles = current_identity.time_tracking_protocols.pluck(:protocol_id, :working_title).to_h
  end

  def time_tracking_params
    params.require(:time_tracking).permit(
      :protocol_id,
      :line_item_id,
      :component_name,
      :date,
      :started_at,
      :ended_at,
      :quantity,
      :notes
    )
  end
end
