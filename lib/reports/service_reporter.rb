class ServiceReporter
  
  def initialize()
    @protocol_service_hash = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
  end
  # create a hash of services,
  #   each of which has a hash of performers (i.e., service providers) with a calculated total quantity work performed
  def add_fulfillment(fulfillment)
    if !@protocol_service_hash.has_key?(fulfillment.service.id) || !@protocol_service_hash[fulfillment.service.id].has_key?(fulfillment.performer.id)
      @protocol_service_hash[fulfillment.service.id][fulfillment.performer.id] = 
                         { :service_name => fulfillment.service.name, 
                           :full_name => fulfillment.performer.full_name,  
                           :quantity_type => fulfillment.quantity_type, 
                           :quantity => fulfillment.quantity }
    else
      @protocol_service_hash[fulfillment.service.id][fulfillment.performer.id][:quantity] += fulfillment.quantity
    end
  end
  
  def get_aggregated_service_provider_fulfillments
    service_provider_fulfillments = []
    @protocol_service_hash.keys.each do |service_id|
      @protocol_service_hash[service_id].keys.each do |performer_id| 
        service_provider_fulfillments << @protocol_service_hash[service_id][performer_id]
      end
    end      
    service_provider_fulfillments
  end
  

end