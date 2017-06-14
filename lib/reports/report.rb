# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
    self.class::VALIDATES_NUMERICALITY_OF.each{ |validates| errors.add(validates, "must be a number") unless @params[validates].is_a?(Numeric) }

    self.class::VALIDATES_PRESENCE_OF.each do |validates|
      if @params[validates].blank?
        errors.add(validates, "must not be blank")
      end
    end
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
    if cost
      dollars = (cost / 100.0) rescue nil
      dollar, cent = dollars.to_s.split('.')
      dollars_formatted = "#{dollar}.#{cent[0..1]}".to_f

      number_to_currency(dollars_formatted, seperator: ",", unit: "")

    else
      "N/A"
    end
  end
end
