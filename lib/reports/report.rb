class Report
  include ActionView::Helpers::NumberHelper

  # Required dependency for ActiveModel::Errors
  extend ActiveModel::Naming

  VALIDATES_PRESENCE_OF = [].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  attr_reader :errors

  def initialize(params)
    @params = params
    @errors = ActiveModel::Errors.new(self)
  end

  def valid?
    VALIDATES_PRESENCE_OF.each{ |validates| errors.add(validates, "must not be blank") if params[validates].blank? }
    VALIDATES_NUMERICALITY_OF.each{ |validates| errors.add(validates, "must be a number") if params[validates].is_a?(Numeric) }

    errors.empty?
  end

  private

  def format_date(date)
    if date.present?
      date.strftime("%m/%d/%Y")
    else
      ''
    end
  end

  def display_cost(cost)
    dollars = (cost / 100) rescue nil
    number_to_currency(dollars, seperator: ",")
  end
end
