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

  scope :fulfilled_in_date_range, ->(start_date, end_date) {
        where("fulfilled_at is not NULL AND DATE(fulfilled_at) between ? AND ?", start_date, end_date)}

  def fulfilled_at=(date)
    write_attribute(:fulfilled_at, Time.strptime(date, "%m-%d-%Y")) if date.present?
  end

  def total_cost
    quantity * service_cost
  end
end
