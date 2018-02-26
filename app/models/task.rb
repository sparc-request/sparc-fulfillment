# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

  has_paper_trail
  acts_as_paranoid

  belongs_to :identity
  belongs_to :assignee,
             class_name: "Identity"
  belongs_to :assignable, polymorphic: true

  belongs_to :procedure, ->{ joins(:tasks).where( tasks: { id: Task.where(assignable_type: 'Procedure' ) } ) }, foreign_key: :assignable_id

  validates :assignee_id, presence: true
  validates :due_at, presence: true

  after_create   :increment_assignee_counter, unless: :complete?
  after_update   :update_assignee_counter
  before_destroy :decrement_assignee_counter, unless: :complete?

  scope :incomplete, -> { where(complete: false) }
  scope :complete, -> { where(complete: true) }
  scope :mine, -> (identity) { where(["identity_id = ? OR assignee_id = ?", identity.id, identity.id]) }
  scope :json_info, -> { includes(:identity, procedure: [protocol: [:sub_service_request], core: [:parent]]) }

  def due_at=(due_date)
    write_attribute(:due_at, Time.strptime(due_date, "%m/%d/%Y")) if due_date.present?
  end

  private

  def increment_assignee_counter
    assignee.update_counter(:tasks, 1)
  end

  def decrement_assignee_counter
    assignee.update_counter(:tasks, -1)
  end

  def update_assignee_counter
    if self.complete_changed?(from: false, to: true)
      decrement_assignee_counter
    elsif self.complete_changed?(from: true, to: false)
      increment_assignee_counter
    end
  end
end
