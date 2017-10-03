# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

class Fulfillment < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid

  belongs_to :line_item
  belongs_to :service
  belongs_to :creator, class_name: "Identity"
  belongs_to :performer, class_name: "Identity"
  has_one :protocol, through: :line_item

  has_many :components, as: :composable
  has_many :notes, as: :notable
  has_many :documents, as: :documentable

  delegate :quantity_type, to: :line_item

  validates :line_item_id, presence: true
  validates :performer_id, presence: true
  validates :fulfilled_at, presence: true
  validates :quantity, presence: true
  validates_numericality_of :quantity

  after_create :update_line_item_name

  scope :fulfilled_in_date_range, ->(start_date, end_date) {
        where("fulfilled_at is not NULL AND fulfilled_at between ? AND ?", start_date, end_date)}

  def fulfilled_at=(date_time)
    write_attribute(:fulfilled_at, Time.strptime(date_time, "%m/%d/%Y")) if date_time.present?
  end

  def total_cost
    quantity * service_cost
  end

  private

  def update_line_item_name
    # adding first fulfillment to line_item with one time fee?
    if line_item.fulfillments.size == 1 && line_item.one_time_fee
      line_item.set_name
    end
  end
end
