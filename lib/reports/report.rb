class Report

  include ActionView::Helpers::NumberHelper

  def initialize(params)
    @params = params
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
