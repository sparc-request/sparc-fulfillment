require 'rails_helper'

RSpec.describe 'Task Index spec', type: :feature, js: true do

  before :each do
    create_tasks(2)
    visit tasks_path
  end

  describe 'initial view' do

    it 'should display the tasks' do
      expect(page).to have_selector('.task-complete', count: 2)
    end

    it 'should display the correct fields' do
      name = Task.first.participant_name
      expect(page).to have_content(name)
    end
  end

  describe 'setting a task as complete' do

    it 'should hide the task once it is complete' do
      first('.task-complete').click
      expect(page).to have_selector('.task-complete', count: 1)
    end
  end

  describe 'rescheduling a task' do

    before :each do
      first('.task-reschedule').click
    end

    it 'should open the modal' do
      expect(page).to have_css "h4.modal-title.text-center", text: "Reschedule"
    end

    it 'close the modal if save is clicked' do
      click_button "Save"
      expect(page).to_not have_css "h4.modal-title.text-center", text: "Reschedule"
    end
  end
end