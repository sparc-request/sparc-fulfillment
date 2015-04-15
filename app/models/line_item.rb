class LineItem < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :protocol
  belongs_to :arm
  belongs_to :service

  has_many :visit_groups, through: :arm
  has_many :visits, -> { includes(:visit_group).order("visit_groups.position") }, dependent: :destroy
  has_many :fulfillments

  delegate  :name,
            :cost,
            :sparc_core_id,
            :sparc_core_name,
            to: :service

  def quantity_remaining
    if otf and !fulfillments.empty?
      remaining = quantity
      fulfillments.each do |f|
        remaining -= f.quantity
      end

      remaining
    else
      quantity
    end
  end

  def date_started
    if otf and !fulfillments.empty?
      fulfillments.dato.first.created_at
    end
  end

  def last_fulfillment
    if otf and !fulfillments.empty?
      fulfillments.dato.last.updated_at
    end
  end
end
