# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

class Arm < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :protocol

  has_many :line_items, dependent: :destroy
  has_many :visit_groups, dependent: :destroy
  has_many :appointments
  has_many :protocols_participants
  has_many :procedures, through: :appointments

  validates :name, presence: true
  validates_uniqueness_of :name, scope: :protocol_id
  validates :name, format: { without: /\[|\]|\*|\/|\\|\?|\:/, message: "cannot contain any of the following: [ ] * / \\ ? :"}
  validates_numericality_of :subject_count, greater_than_or_equal_to: 1
  validates_numericality_of :visit_count, greater_than_or_equal_to: 1

  default_scope { where(marked_for_deletion: false) }


  def destroy_later
    if protocol.arms.count < 2
      errors.add(:arm, "Cannot remove the last Arm of this Protocol. All protocols must have at least one Arm")
      return false
    elsif Procedure.where(appointment: appointments).touched.any?
      errors.add(:arm, "'#{name}' has completed procedures and cannot be deleted")
      return false
    else
      update_attributes(marked_for_deletion: true)
      DelayedDestroyJob.perform_later self
      return true
    end
  end
end
