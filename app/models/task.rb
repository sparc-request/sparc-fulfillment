# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

class Task < ApplicationRecord

  require 'csv'

  has_paper_trail
  acts_as_paranoid

  belongs_to :identity
  belongs_to :assignee,
             class_name: "Identity", foreign_key: "assignee_id"
  belongs_to :assignable, polymorphic: true

  belongs_to :procedure, ->{ joins(:tasks).where( tasks: { id: Task.where(assignable_type: 'Procedure' ) } ) }, foreign_key: :assignable_id

  validates :assignee_id, presence: true
  validates :due_at, presence: true

  after_create   :increment_assignee_counter, unless: :complete?
  after_update   :update_assignee_counter
  before_destroy :decrement_assignee_counter, unless: :complete?

  scope :incomplete, -> { where(complete: false) }
  scope :complete, -> { where(complete: true) }
  scope :mine, -> (identity) { where(["tasks.identity_id = ? OR tasks.assignee_id = ?", identity.id, identity.id]) }
  scope :json_info, -> { includes(:identity, procedure: [protocol: [:sub_service_request], core: [:parent]]) }


  scope :sorted, -> (sort, order) {
    sort  = 'id' if sort.blank?
    order = 'desc' if order.blank?

    order(sort => order)
  }

  def self.to_csv(tasks)
    CSV.generate do |csv|
      csv << [Protocol.human_attribute_name(:id),
              I18n.t('task.identity_name'),
              I18n.t('task.assignee_name'),
              I18n.t('task.assignable_type'),
              Task.human_attribute_name(:body),
              Task.human_attribute_name(:due_at),
              I18n.t('task.completed'),
              I18n.t('procedure.prog_core')]
      tasks.each do |t|
        csv << [ t.assignable_type == 'Procedure' ? t.procedure.protocol.srid : '',
                t.identity.full_name,
                t.assignee.full_name,
                t.assignable_type,
                t.body,
                t.due_at.strftime('%m/%d/%Y'),
                t.complete,
                t.assignable_type == 'Procedure' ? "#{t.procedure.core.name} / #{t.procedure.core.parent.name}" : '']
      end
    end
  end

  private

  def increment_assignee_counter
    assignee.update_counter(:tasks, 1)
  end

  def decrement_assignee_counter
    assignee.update_counter(:tasks, -1)
  end

  def update_assignee_counter
    if saved_change_to_complete?(from: false, to: true)
      decrement_assignee_counter
    elsif saved_change_to_complete?(from: true, to: false)
      increment_assignee_counter
    end
  end
end
