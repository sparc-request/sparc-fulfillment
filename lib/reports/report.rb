class Report
  include ActionView::Helpers::NumberHelper

  # Required dependency for ActiveModel::Errors
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  attr_reader :errors

  def initialize(params)
    @params = params
    @errors = ActiveModel::Errors.new(self)
  end

  def valid?
    self.class::VALIDATES_PRESENCE_OF.each{ |validates| errors.add(validates, "must not be blank") if @params[validates].blank? }
    self.class::VALIDATES_NUMERICALITY_OF.each{ |validates| errors.add(validates, "must be a number") unless @params[validates].is_a?(Numeric) }

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
    dollars = (cost / 100.0) rescue nil
    dollar, cent = dollars.to_s.split('.')
    dollars_formatted = "#{dollar}.#{cent[0..1]}".to_f

    number_to_currency(dollars_formatted, seperator: ",")
  end
end
