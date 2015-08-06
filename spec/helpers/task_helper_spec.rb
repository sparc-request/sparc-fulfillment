require 'rails_helper'

RSpec.describe TaskHelper do

  describe "format_task_type" do
    it "should return html to render the task type" do
      identity = create(:identity)
      task = create(:task, identity: identity)

      #Task type is 'Procedure'
      procedure = create(:procedure)
      task.update_attributes(assignable_type: "Procedure")
      task.update_attributes(assignable_id: procedure.id)
      expect(helper.format_task_type(task)).to eq(task.assignable_type+" (#{task.assignable.service_name})")

      #Task type is not 'Procedure'
      task.update_attributes(assignable_type: "Identity")
      expect(helper.format_task_type(task)).to eq(task.assignable_type)      
    end
  end
end
