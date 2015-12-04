require 'csv'

class Report

  include ActionView::Helpers::NumberHelper

  attr_accessor :title,
                :start_date,
                :end_date,
                :protocol_id,
                :protocol_ids

  def initialize(attributes = Hash.new)
    @attributes = attributes

    if attributes[:start_date].present?
      @start_date = Time.parse attributes[:start_date]
    end
    if attributes[:end_date].present?
      @end_date = Time.parse attributes[:end_date]
    end
  end

  def kind
    self.class
  end

  private

  def format_date(date)
    if date.present?
      date.strftime('%m/%d/%Y')
    else
      ''
    end
  end

  def display_cost(cost = nil)
    if cost.present?
      dollars = (cost / 100.0) rescue nil
      dollar, cent = dollars.to_s.split('.')
      dollars_formatted = "#{dollar}.#{cent[0..1]}".to_f

      number_to_currency(dollars_formatted, seperator: ',', unit: '')
    else
      'N/A'
    end
  end
end
