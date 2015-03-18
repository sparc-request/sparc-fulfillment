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

  describe 'creating a new task from index page' do

    before :each do
      click_link "Create New Task"
    end

    it 'should open the modal' do
      expect(page).to have_css "h4.modal-title.text-center", text: "Create Task"
    end

    it "should create a new task" do
      user_fills_in_new_task_form
      wait_for_javascript_to_finish
      tasks_size = Task.all.count
      click_button 'Save'
      wait_for_javascript_to_finish
      expect(Task.all.count).to eq(tasks_size + 1)
    end

    it "should not create a task if the correct fields are not filled out." do
      tasks_size = Task.all.count
      click_button 'Save'
      wait_for_javascript_to_finish
      expect(Task.all.count).to_not eq(tasks_size + 1)
    end
  end

  describe "setting a task back to incomplete" do

    before :each do
      @complete_task = Task.first
      @complete_task.update_attributes(is_complete: true)
      click_button "completed_tasks"
    end

    it "should render the modal" do
      expect(page).to have_css "#incomplete_tasks_modal"
    end

    it "should have completed tasks listed in the modal" do
      expect(page).to have_css "#completed_task_#{@complete_task.id}"
    end

    it "should incomplete tasks using checkboxes and submitting the form" do
      find(:css, "input#incompletes_[value='#{@complete_task.id}']").set(true)
      click_button "Save"
      expect(page).to have_css ".alert.alert-dismissable.alert-success"
    end

    it "should update the task table" do
      find(:css, "input#incompletes_[value='#{@complete_task.id}']").set(true)
      click_button "Save"
      expect(page).to have_css ".alert.alert-dismissable.alert-success"
      expect(page).to have_content "#{@complete_task.task}"
    end

  end
end
