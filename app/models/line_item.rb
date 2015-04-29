class LineItem < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid

  belongs_to :protocol
  belongs_to :arm
  belongs_to :service

  has_many :visit_groups, through: :arm
  has_many :visits, -> { includes(:visit_group).order("visit_groups.position") }, dependent: :destroy
  has_many :notes, as: :notable
  has_many :documents, as: :documentable
  has_many :fulfillments
  has_many :components, as: :composable

  delegate  :name,
            :cost,
            :sparc_core_id,
            :sparc_core_name,
            :one_time_fee,
            to: :service

  def quantity_remaining
    if one_time_fee and !fulfillments.empty?
      remaining = quantity_requested
      fulfillments.each do |f|
        remaining -= f.quantity
      end

      remaining
    else
      quantity_requested
    end
  end

  def last_fulfillment
    if one_time_fee and !fulfillments.empty?
      fulfillments.order('fulfilled_at DESC').first.fulfilled_at
    end
  end
end
