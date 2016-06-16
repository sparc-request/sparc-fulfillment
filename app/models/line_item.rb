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
  has_many :admin_rates, primary_key: :sparc_id

  delegate  :name,
            :sparc_core_id,
            :sparc_core_name,
            :one_time_fee,
            to: :service,
            allow_nil: true

  validates :protocol_id, :service_id, presence: true
  validates :quantity_requested, presence: true, numericality: { greater_than: 0 }, if: Proc.new { |li| li.one_time_fee }

  after_create :create_line_item_components
  after_create :increment_sparc_service_counter
  after_destroy :decrement_sparc_service_counter

  def set_name
    update_attributes(name: service.name)
  end

  def name
    if one_time_fee && has_fulfillments?
      read_attribute(:name)
    else
      service.name
    end
  end

  def cost(funding_source = protocol.sparc_funding_source, date = Time.current)
    if admin_rates.any?
      admin_rates.last.admin_cost
    else
      service.cost(funding_source, date)
    end
  end

  def name=(n)
    write_attribute(:name, n)
  end

  def increment_sparc_service_counter
    service.increment(:line_items_count)
  end

  def decrement_sparc_service_counter
    service.decrement(:line_items_count)
  end

  def started_at=(date)
    write_attribute(:started_at, Time.strptime(date, "%m/%d/%Y")) if date.present?
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

  def has_fulfillments?
    !fulfillments.empty?
  end

  def last_fulfillment
    if one_time_fee and !fulfillments.empty?
      fulfillments.order('fulfilled_at DESC').first.fulfilled_at
    end
  end

  private

  def create_line_item_components
    if one_time_fee && service.components.present?
      position = 0
      service.components.split(',').each do |component|
        Component.create(composable_type: 'LineItem', composable_id: id, component: component, position: position)
        position += 1
      end
    end
  end
end
