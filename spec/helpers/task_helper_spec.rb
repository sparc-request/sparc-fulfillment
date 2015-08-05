require 'rails_helper'

RSpec.describe TaskHelper do

  describe "#format_reschedule" do
    it "should return html to render the reschedule icon" do
      task_id = 1
      html_return = format_reschedule_return(task_id)
      expect(helper.format_reschedule(task_id)).to eq(html_return)
    end
  end

  describe "#format_checkbox" do
    it "should return html to render the checkbox" do
      identity = create(:identity)
      task = create(:task, identity: identity)
      html_return = format_checkbox_return(task)
      expect(helper.format_checkbox(task)).to eq(html_return)
    end
  end

  describe "format_task_type" do
    it "should return html to render the task type" do
      identity = create(:identity)
      task = create(:task, identity: identity)

      #Task type is 'Procedure'
      procedure = create(:procedure)
      task.update_attributes(assignable_type: "Procedure")
      task.update_attributes(assignable_id: procedure.id)
      expect(helper.format_task_type(task)).to eq(format_task_type_return(task))

      #Task type is not 'Procedure'
      task.update_attributes(assignable_type: "Identity")
      expect(helper.format_task_type(task)).to eq(format_task_type_return(task))      
    end
  end

  def format_reschedule_return task_id
    html = '-'
    icon = raw content_tag(:i, '', class: "glyphicon glyphicon-calendar")
    html = raw content_tag(:a, raw(icon), class: 'task-reschedule', href: 'javascript:void(0)', task_id: task_id)

    html
  end

  def format_checkbox_return task
    html = '-'
    html = raw content_tag(:input, '', class: 'complete', name: 'complete', type: 'checkbox', task_id: task.id, checked: task.complete? ? "checked" : nil)

    html
  end

  def format_task_type_return task
    task_type = task.assignable_type
    task_type += " (#{task.assignable.service_name})" if task_type == "Procedure"

    task_type
  end
end