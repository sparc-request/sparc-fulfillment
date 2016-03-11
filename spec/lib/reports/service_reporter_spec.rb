require 'rails_helper'

RSpec.describe ServiceReporter do

  describe "adding services with fulfillments" do
    before :each do
      @service = Service.new
      @service.id = 1
      @service.name = "Web app development"
        
      @line_item = LineItem.new
      @line_item.quantity_type = "hours"
      
      @performer = Identity.new
      @performer.id = 1
      @performer.first_name = "John"
      @performer.last_name = "Doe"

      @fulfillment = Fulfillment.new
      @fulfillment.id = 1
      @fulfillment.quantity = BigDecimal.new(2)
      @fulfillment.performer = @performer
      @fulfillment.service = @service
      @fulfillment.line_item = @line_item
    end
    
    it 'should return an empty array when no data has been added' do        
      @service_reporter = ServiceReporter.new        
      expect(@service_reporter.get_aggregated_service_provider_fulfillments).to eq([])   
    end
      
    it 'should return an array with one service + one performer with one fulfillment' do      
      @service_reporter = ServiceReporter.new        
      @service_reporter.add_fulfillment(@fulfillment)
      
      array_of_service_providers = @service_reporter.get_aggregated_service_provider_fulfillments
      expect(array_of_service_providers.length).to eq(1)  
      expect(array_of_service_providers[0]).to include(:service_name => "Web app development", :full_name => "John Doe", :quantity => BigDecimal.new(2), :quantity_type => "hours")        
    end
    
    it 'should return an array with one service + one performer with two identical fulfillments that have quantity aggregated' do      
      @service_reporter = ServiceReporter.new        
      @service_reporter.add_fulfillment(@fulfillment)
      @service_reporter.add_fulfillment(@fulfillment)
      
      array_of_service_providers = @service_reporter.get_aggregated_service_provider_fulfillments
      expect(array_of_service_providers.length).to eq(1)  
      expect(array_of_service_providers[0]).to include(:service_name => "Web app development", :full_name => "John Doe", :quantity => BigDecimal.new(4), :quantity_type => "hours")        
    end
    
    it 'should return an array with one service + one performer with two different fulfillments that have quantity aggregated' do      
      @service_reporter = ServiceReporter.new        
      @service_reporter.add_fulfillment(@fulfillment)
      
      @fulfillment_two = Fulfillment.new
      @fulfillment_two.id = 2
      @fulfillment_two.quantity = BigDecimal.new(3)
      @fulfillment_two.performer = @performer
      @fulfillment_two.service = @service
      @fulfillment_two.line_item = @line_item
      
      @service_reporter.add_fulfillment(@fulfillment_two)
      
      array_of_service_providers = @service_reporter.get_aggregated_service_provider_fulfillments
      expect(array_of_service_providers.length).to eq(1)  
      expect(array_of_service_providers[0]).to include(:service_name => "Web app development", :full_name => "John Doe", :quantity => BigDecimal.new(5), :quantity_type => "hours")        
    end
    
    it 'should return an array with one service + two performers each with two different fulfillments that have quantity aggregated' do      
      @service_reporter = ServiceReporter.new        
      @service_reporter.add_fulfillment(@fulfillment)
      
      @fulfillment_two = Fulfillment.new
      @fulfillment_two.id = 2
      @fulfillment_two.quantity = BigDecimal.new(3)
      @fulfillment_two.performer = @performer
      @fulfillment_two.service = @service
      @fulfillment_two.line_item = @line_item
      
      @service_reporter.add_fulfillment(@fulfillment_two)
      
      @performer_two = Identity.new
      @performer_two.id = 2
      @performer_two.first_name = "Jane"
      @performer_two.last_name = "Doe"

      @fulfillment_three = Fulfillment.new
      @fulfillment_three.id = 3
      @fulfillment_three.quantity = BigDecimal.new(4)
      @fulfillment_three.performer = @performer_two
      @fulfillment_three.service = @service
      @fulfillment_three.line_item = @line_item
      
      @service_reporter.add_fulfillment(@fulfillment_three)
      
      @fulfillment_four = Fulfillment.new
      @fulfillment_four.id = 4
      @fulfillment_four.quantity = BigDecimal.new(5)
      @fulfillment_four.performer = @performer_two
      @fulfillment_four.service = @service
      @fulfillment_four.line_item = @line_item
      
      @service_reporter.add_fulfillment(@fulfillment_four)
      
      array_of_service_providers = @service_reporter.get_aggregated_service_provider_fulfillments
      expect(array_of_service_providers.length).to eq(2)  
      expect(array_of_service_providers[0]).to include(:service_name => "Web app development", :full_name => "John Doe", :quantity => BigDecimal.new(5), :quantity_type => "hours")
      expect(array_of_service_providers[1]).to include(:service_name => "Web app development", :full_name => "Jane Doe", :quantity => BigDecimal.new(9), :quantity_type => "hours")                                                          
    end
    
    it 'should return an array with two services + two performers each with one fulfillments on each service that have quantity aggregated' do      
      @service_reporter = ServiceReporter.new        
      @service_reporter.add_fulfillment(@fulfillment)
      
      @service_two = Service.new
      @service_two.id = 2
      @service_two.name = "DBA consulting"
      
      @fulfillment_two = Fulfillment.new
      @fulfillment_two.id = 2
      @fulfillment_two.quantity = BigDecimal.new(3)
      @fulfillment_two.performer = @performer
      @fulfillment_two.service = @service_two
      @fulfillment_two.line_item = @line_item
      
      @service_reporter.add_fulfillment(@fulfillment_two)
      
      @performer_two = Identity.new
      @performer_two.id = 2
      @performer_two.first_name = "Jane"
      @performer_two.last_name = "Doe"
    
      @fulfillment_three = Fulfillment.new
      @fulfillment_three.id = 3
      @fulfillment_three.quantity = BigDecimal.new(4)
      @fulfillment_three.performer = @performer_two
      @fulfillment_three.service = @service_two
      @fulfillment_three.line_item = @line_item
      
      @service_reporter.add_fulfillment(@fulfillment_three)
      
      @fulfillment_four = Fulfillment.new
      @fulfillment_four.id = 4
      @fulfillment_four.quantity = BigDecimal.new(5)
      @fulfillment_four.performer = @performer_two
      @fulfillment_four.service = @service
      @fulfillment_four.line_item = @line_item
      
      @service_reporter.add_fulfillment(@fulfillment_four)
      
      array_of_service_providers = @service_reporter.get_aggregated_service_provider_fulfillments
      expect(array_of_service_providers.length).to eq(4)  
      expect(array_of_service_providers[0]).to include(:service_name => "Web app development", :full_name => "John Doe", :quantity => BigDecimal.new(2), :quantity_type => "hours")
      expect(array_of_service_providers[1]).to include(:service_name => "Web app development", :full_name => "Jane Doe", :quantity => BigDecimal.new(5), :quantity_type => "hours")        
      expect(array_of_service_providers[2]).to include(:service_name => "DBA consulting", :full_name => "John Doe", :quantity => BigDecimal.new(3), :quantity_type => "hours")
      expect(array_of_service_providers[3]).to include(:service_name => "DBA consulting", :full_name => "Jane Doe", :quantity => BigDecimal.new(4), :quantity_type => "hours")                                                                                                            
    end  
    
    it 'should return an array with two services + two performers each with two fulfillments on a service' do      
      @service_reporter = ServiceReporter.new        
      @service_reporter.add_fulfillment(@fulfillment)
     
      @fulfillment_two = Fulfillment.new
      @fulfillment_two.id = 2
      @fulfillment_two.quantity = BigDecimal.new(3)
      @fulfillment_two.performer = @performer
      @fulfillment_two.service = @service
      @fulfillment_two.line_item = @line_item
      
      @service_reporter.add_fulfillment(@fulfillment_two)
      
      @service_two = Service.new
      @service_two.id = 2
      @service_two.name = "DBA consulting"
      
      @performer_two = Identity.new
      @performer_two.id = 2
      @performer_two.first_name = "Jane"
      @performer_two.last_name = "Doe"
    
      @fulfillment_three = Fulfillment.new
      @fulfillment_three.id = 3
      @fulfillment_three.quantity = BigDecimal.new(4)
      @fulfillment_three.performer = @performer_two
      @fulfillment_three.service = @service_two
      @fulfillment_three.line_item = @line_item
      
      @service_reporter.add_fulfillment(@fulfillment_three)
      
      @fulfillment_four = Fulfillment.new
      @fulfillment_four.id = 4
      @fulfillment_four.quantity = BigDecimal.new(5)
      @fulfillment_four.performer = @performer_two
      @fulfillment_four.service = @service_two
      @fulfillment_four.line_item = @line_item
      
      @service_reporter.add_fulfillment(@fulfillment_four)
      
      array_of_service_providers = @service_reporter.get_aggregated_service_provider_fulfillments
      expect(array_of_service_providers.length).to eq(2)  
      expect(array_of_service_providers[0]).to include(:service_name => "Web app development", :full_name => "John Doe", :quantity => BigDecimal.new(5), :quantity_type => "hours")
      expect(array_of_service_providers[1]).to include(:service_name => "DBA consulting", :full_name => "Jane Doe", :quantity => BigDecimal.new(9), :quantity_type => "hours")                                                                                                            
      # example loop to be used within a report
      #@service_reporter.get_aggregated_service_provider_fulfillments.each do |service_provider_fulfillments|
      #      puts "#{service_provider_fulfillments[:service_name]}, #{service_provider_fulfillments[:full_name]}, #{service_provider_fulfillments[:quantity]}, #{service_provider_fulfillments[:quantity_type]}"
      # end
      
    end        
  end
end

