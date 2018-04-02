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

class Note < ApplicationRecord

  KIND_TYPES    = %w(log note reason followup).freeze

  has_paper_trail
  acts_as_paranoid

  belongs_to :notable, polymorphic: true
  belongs_to :identity

  validates_inclusion_of :kind, in: KIND_TYPES

  validates :reason, presence: true, if: Proc.new { |note| ((note.notable_type == 'Procedure') || (note.notable_type == 'Appointment')) && note.kind == 'reason' }
  validates_inclusion_of :reason, in: Proc.new { |note| note.notable_type.constantize::NOTABLE_REASONS },
                                  if: Proc.new { |note| note.reason.present? }

  # required so that custom appointment notes will show. up.  taken from the rails documentation, http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#label-Polymorphic+Associations

  def notable_type=(class_name)
    super(class_name.constantize.base_class.to_s)
  end

  def comment
    case kind
    when 'followup'
      [
        'Followup',
        notable.task.due_at.strftime('%F'),
        read_attribute(:comment)
      ].compact.join(': ')
    when 'reason'
      [
        read_attribute(:reason),
        read_attribute(:comment)
      ].compact.join(': ')
    else
      read_attribute(:comment)
    end
  end

  def reason?
    kind == 'reason'
  end

  def followup?
    kind == 'followup'
  end

  def log?
    kind == 'log'
  end

  def note?
    kind == 'note'
  end

  def unique_selector
    "#{notable_type.downcase}_#{notable_id}"
  end
end
