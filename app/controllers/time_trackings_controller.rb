class TimeTrackingsController < ApplicationController
  before_action :authorize_time_tracking
  before_action { @highlighted_link = 'time_trackings' }

  def index
    respond_to do |format|
      format.html do
        # Load 'My Time Entries' sidebar data
        load_sidebar_data

        # Load 'Team Approval' filter dropdowns
        if current_identity.time_tracking_manager?
          managed_scope = TimeTracking.managed_by(current_identity).where.not(ended_at: nil)

          staff_ids = managed_scope.distinct.pluck(:identity_id)
          @staff_members = Identity.where(id: staff_ids)
            .order(:last_name, :first_name)
            .map { |i| [i.full_name, i.id] } # <option value=i.id>i.full_name</option>

          protocol_ids = managed_scope.distinct.pluck(:protocol_id)
          @managed_protocols = Protocol.where(id: protocol_ids)
            .includes(:sub_service_request, :sparc_protocol)
            .map { |p| ["(#{p.srid}) #{p.short_title}".truncate(65), p.id] }
            .sort_by(&:first)
        end
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
    @stopped_timers = TimeTracking.stop_active_for(current_identity)

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

    if @time_tracking.update(
      date: parsed_date || date_str,
      started_at: started_at || time_tracking_params[:started_at],
      ended_at: ended_at || time_tracking_params[:ended_at],
      quantity: diff_hours || time_tracking_params[:quantity],
      component_name: time_tracking_params[:component_name],
      notes: time_tracking_params[:notes]
    )
    else
      @errors = @time_tracking.errors
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

  # Update protocols list in 'My Time Entries' sidebar
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
    protocols_data = current_identity.clinical_provider_protocols
      .joins(:sub_service_request, :sparc_protocol)
      .pluck(
        Protocol.arel_table[:id],
        Protocol.arel_table[:sparc_id],
        SubServiceRequest.arel_table[:ssr_id],
        Sparc::Protocol.arel_table[:short_title]
      )

    @available_protocols = protocols_data
      .sort_by { |_id, sparc_id, ssr_id, _title| [sparc_id.to_i, ssr_id.to_i] }
      .map do |id, sparc_id, ssr_id, short_title|
        ["(#{sparc_id}-#{ssr_id}) #{short_title}".truncate(90), id]
      end

    @selected_protocol_ids = current_identity.time_tracking_protocols.pluck(:protocol_id)

    respond_to do |format|
      format.js
      format.html { redirect_to time_trackings_path }
    end
  end

  # json data for 'Team Approval' table
  def team_approval
    @team_time_trackings = TimeTracking.managed_by(current_identity)
      .where.not(ended_at: nil)
      .includes(:identity, protocol: [:sparc_protocol, :sub_service_request, :pi], line_item: :service)
      .order(date: :desc, started_at: :desc)

    if params[:identity_id].present?
      @team_time_trackings = @team_time_trackings.where(identity_id: params[:identity_id])
    end

    if params[:protocol_id].present?
      @team_time_trackings = @team_time_trackings.where(protocol_id: params[:protocol_id])
    end

    if params[:date_from].present?
      date_from = Date.strptime(params[:date_from], '%m/%d/%Y') rescue nil
      @team_time_trackings = @team_time_trackings.where('date >= ?', date_from) if date_from
    end

    if params[:date_to].present?
      date_to = Date.strptime(params[:date_to], '%m/%d/%Y') rescue nil
      @team_time_trackings = @team_time_trackings.where('date <= ?', date_to) if date_to
    end

    if params[:status].present?
      statuses = Array(params[:status])
      if statuses.include?(TimeTracking::IN_PROGRESS)
        @team_time_trackings = @team_time_trackings.where("status in (?) or status is null", statuses)
      else
        @team_time_trackings = @team_time_trackings.where(status: statuses)
      end
    end

    respond_to do |format|
      format.json
    end
  end

  def update_status
    ids = Array(params[:ids]).map(&:to_i)
    time_trackings = TimeTracking.managed_by(current_identity).where(id: ids)
    time_trackings.update_all(status: params[:status])

    render json: { success: true, count: time_trackings.count }
  end

  def import_to_fulfillments
    ids = Array(params[:ids]).map(&:to_i)
    time_trackings = TimeTracking.managed_by(current_identity)
      .where(id: ids)
      .includes(:fulfillment, :line_item, :protocol)

    ActiveRecord::Base.transaction do
      time_trackings.each { |tt| tt.import_to_fulfillment!(current_identity) }
    end

    render json: { success: true, count: time_trackings.size }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def authorize_time_tracking
    unless current_identity.can_access_time_tracking?
      flash[:alert] = t(:protocol)[:flash_messages][:unauthorized]
      redirect_to root_path
    end
  end

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
