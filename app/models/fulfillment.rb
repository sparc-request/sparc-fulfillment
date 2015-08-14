class Fulfillment < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid

  belongs_to :line_item
  belongs_to :service
  belongs_to :creator, class_name: "Identity"
  belongs_to :performer, class_name: "Identity"

  has_many :components, as: :composable
  has_many :notes, as: :notable
  has_many :documents, as: :documentable

  delegate :quantity_type, to: :line_item

  validates :line_item_id, :performer_id, :fulfilled_at, :quantity, presence: true
  validates_numericality_of :quantity
  validates_length_of :account_number, :maximum => 30

  after_create :update_line_item_name

  scope :fulfilled_in_date_range, ->(start_date, end_date) {
        where("fulfilled_at is not NULL AND DATE(fulfilled_at) between ? AND ?", start_date.to_date, end_date.to_date)}

  def fulfilled_at=(date)
    write_attribute(:fulfilled_at, Time.strptime(date, "%m-%d-%Y")) if date.present?
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
