# Copyright © 2011-2017 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class ProtocolImporter

  def initialize(callback_url)
    @callback_url = callback_url
    @logger = Logger.new(File.join(Rails.root, 'log', "protocol_importer-#{Rails.env}.log"))
  end

  def create
    PaperTrail.enabled = false

    api_sub_service_request = RemoteObjectFetcher.fetch(@callback_url)["sub_service_request"]

    ### logic driven fields, easier to go a head and use them from the api call
    grand_total            = api_sub_service_request['grand_total']

    sparc_sub_service_request = Sparc::SubServiceRequest.find api_sub_service_request["sparc_id"]
    sparc_protocol = sparc_sub_service_request.protocol
    fulfillment_protocol = nil # need this to return at the end

    ActiveRecord::Base.transaction do
      @logger.info "ActiveRecord transaction started for sparc_sub_service_request: #{sparc_sub_service_request.inspect}"
      # protocol creation
      attr = normalized_attributes('Protocol', sparc_protocol).merge!({sparc_id: sparc_protocol.id,
                                                                       study_cost: grand_total,
                                                                       sub_service_request_id: sparc_sub_service_request.id})
      fulfillment_protocol = validate_and_save(Protocol.new(attr))
      # end protocol creation

      if fulfillment_protocol.organization.inclusive_child_services(:per_participant).present?
        sparc_protocol.arms.each do |sparc_arm|

          # arm creation
          attr = normalized_attributes('Arm', sparc_arm).merge!({sparc_id: sparc_arm.id,
                                                                 protocol_id: fulfillment_protocol.id})

          fulfillment_arm = validate_and_save(Arm.new(attr))
          # end arm creation

          sparc_arm.visit_groups.order(:position).each do |sparc_visit_group|

            # visit_group creation
            attr = normalized_attributes('VisitGroup', sparc_visit_group).merge!({sparc_id: sparc_visit_group.id,
                                                                                  arm_id: fulfillment_arm.id})

            fulfillment_visit_group = validate_and_save(VisitGroup.new(attr))
            #comment out above and use below if you don't want to validate visit group attributes, useful for initial bulk import
            #fulfillment_visit_group = VisitGroup.new(attr)
            #fulfillment_visit_group.save(validate: false)
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
                  fulfillment_line_item = validate_and_save(LineItem.new(attr))
                  # end per participant line_item creation
                end

                # visit creation
                attr = normalized_attributes('Visit', sparc_visit).merge!({sparc_id: sparc_visit.id,
                                                                           visit_group_id: fulfillment_visit_group.id,
                                                                           line_item_id: fulfillment_line_item.id})
                fulfillment_visit = validate_and_save(Visit.new(attr))
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
        fulfillment_line_item = validate_and_save(LineItem.new(attr))

      end
      # end one_time_fee line_item creation

      # update views via Faye
      FayeJob.perform_later fulfillment_protocol
      # end Faye
      @logger.info "ActiveRecord transaction completed for sparc_sub_service_request: #{sparc_sub_service_request.inspect}"
    end # end Active Record Transaction

    PaperTrail.enabled = true

    # return the new created protocol
    return fulfillment_protocol
  end

  private

  def normalized_attributes klass_name, object
    RemoteObjectNormalizer.new(klass_name, object.attributes).normalize!
  end

  def validate_and_save object
    if object.valid?
      object.save
    else
      @logger.info "#"*50
      @logger.info "Invalid object #{object.errors.inspect}"
      @logger.info "#"*50
      raise ActiveRecord::Rollback
    end

    object
  end
end
