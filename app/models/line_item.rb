class LineItem < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid

  belongs_to :protocol
  belongs_to :arm
  belongs_to :service

  has_many :visit_groups, through: :arm
  has_many :visits, -> { includes(:visit_group).order("visit_groups.position") }, dependent: :destroy
  has_many :fulfillments
  has_many :notes, as: :notable
  has_many :documents, as: :documentable
  has_many :components, as: :composable

  delegate  :name,
            :cost,
            :sparc_core_id,
            :sparc_core_name,
            :one_time_fee,
            to: :service,
            allow_nil: true

  validates :protocol_id, :service_id, presence: true
  validate :one_time_fee_fields

  after_create :create_line_item_components
  after_create :increment_sparc_service_counter
  after_destroy :decrement_sparc_service_counter

  def increment_sparc_service_counter
    service.increment(:line_items_count)
  end

  def decrement_sparc_service_counter
    service.decrement(:line_items_count)
  end

  def started_at=(date)
    write_attribute(:started_at, Time.strptime(date, "%m-%d-%Y")) if date.present?
  end

  def one_time_fee_fields
    if one_time_fee
      errors.add(:quantity_requested, "can't be blank") if not quantity_requested.present?
      errors.add(:quantity_requested, "is not a number") if not quantity_requested.is_a? Integer
      errors.add(:quantity_type, "can't be blank") if not quantity_type.present?
    end
  end

  def all_components
    components.with_deleted
  end

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

  private

  def create_line_item_components
    if one_time_fee
      position = 0
      service.components.split(',').each do |component|
        Component.create(composable_type: 'LineItem', composable_id: id, component: component, position: position)
        position += 1
      end
    end
  end
end
