class ProtocolImporter

  def initialize(callback_url)
    @callback_url = callback_url
  end

  def create
    PaperTrail.enabled = false

    api_sub_service_request = RemoteObjectFetcher.fetch(@callback_url)["sub_service_request"]

    ### logic driven fields, easier to go a head and use them from the api call
    grand_total            = api_sub_service_request['grand_total']
    stored_percent_subsidy = api_sub_service_request['stored_percent_subsidy']
    status                 = api_sub_service_request['status']

    sparc_sub_service_request = Sparc::SubServiceRequest.find api_sub_service_request["sparc_id"]
    sparc_protocol = sparc_sub_service_request.protocol

    ActiveRecord::Base.transaction do

      # protocol creation
      attr = normalized_attributes('Protocol', sparc_protocol).merge!({sparc_id: sparc_protocol.id,
                                                                       study_cost: grand_total,
                                                                       stored_percent_subsidy: stored_percent_subsidy,
                                                                       status: status,
                                                                       sub_service_request_id: sparc_sub_service_request.id})

      fulfillment_protocol = Protocol.create(attr)
      # end protocol creation

      if fulfillment_protocol.organization.inclusive_child_services(:per_participant).present?
        sparc_protocol.arms.each do |sparc_arm|

          # arm creation
          attr = normalized_attributes('Arm', sparc_arm).merge!({sparc_id: sparc_arm.id,
                                                                 protocol_id: fulfillment_protocol.id})

          fulfillment_arm = Arm.create(attr)
          # end arm creation

          sparc_arm.visit_groups.each do |sparc_visit_group|
            
            # visit_group creation
            attr = normalized_attributes('VisitGroup', sparc_visit_group).merge!({sparc_id: sparc_visit_group.id,
                                                                                  arm_id: fulfillment_arm.id})
            fulfillment_visit_group = VisitGroup.create(attr)
            # end visit_group creation

            sparc_visit_group.visits.each do |sparc_visit|
              sparc_line_item = sparc_visit.line_items_visit.line_item
              
              if sparc_line_item.sub_service_request.id == sparc_sub_service_request.id

                unless fulfillment_line_item = LineItem.where(sparc_id: sparc_line_item.id, arm_id: fulfillment_arm.id).first
                  # per_participant line_item creation if it doesn't already exist
                  attr = normalized_attributes('LineItem', sparc_line_item).merge!({sparc_id: sparc_line_item.id,
                                                                                    protocol_id: fulfillment_protocol.id,
                                                                                    subject_count: sparc_visit.line_items_visit.subject_count,
                                                                                    arm_id: fulfillment_arm.id})
                  fulfillment_line_item = LineItem.create(attr)
                  # end per participant line_item creation
                end
            
                # visit creation
                attr = normalized_attributes('Visit', sparc_visit).merge!({sparc_id: sparc_visit_group.id,
                                                                           visit_group_id: fulfillment_visit_group.id,
                                                                           line_item_id: fulfillment_line_item.id})
                fulfillment_visit = Visit.create(attr)
                # end visit creation
              end
             
            end # visits loop
          end # visit_groups loop
        end # arms loop
      end # per_participant services.present?

      # one_time_fee line_item creation
      sparc_sub_service_request.one_time_fee_line_items.each do |sparc_line_item|
        sparc_line_item_quantity            = sparc_line_item.quantity || 0
        sparc_line_item_units_per_quantity  = sparc_line_item.units_per_quantity || 1
        sparc_line_item_quantity_requested  = sparc_line_item_quantity * sparc_line_item_units_per_quantity 
        
        attr = normalized_attributes('LineItem', sparc_line_item).merge!({sparc_id: sparc_line_item.id,
                                                                          protocol_id: fulfillment_protocol.id,
                                                                          quantity_requested: sparc_line_item_quantity_requested,
                                                                          quantity_type: sparc_line_item.service.current_effective_pricing_map.quantity_type})
        fulfillment_line_item = LineItem.create(attr)
      end
      # end one_time_fee line_item creation
      
      # update views via Faye
      FayeJob.enqueue(fulfillment_protocol)
      # end Faye

    end # end Active Record Transaction

    PaperTrail.enabled = true
  end

  private

  def normalized_attributes klass_name, object
    RemoteObjectNormalizer.new(klass_name, object.attributes).normalize!
  end
end
