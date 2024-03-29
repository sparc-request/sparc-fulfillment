# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

class PricingMap < SparcDbBase
  belongs_to :service

  scope :current, -> (date) { where("effective_date <= ?", date).order("effective_date DESC").limit(1) }

##  COPIED FROM SPARC-REQUEST    ##
  def applicable_rate(rate_type, default_percentage)
    rate = rate_override(rate_type)
    rate ||= calculate_rate(default_percentage)

    rate
  end

  def rate_override(rate_type)
    case rate_type
    when 'federal'    then self.federal_rate
    when 'corporate'  then self.corporate_rate
    when 'member'     then self.member_rate
    when 'other'      then self.other_rate
    when 'full'       then self.full_rate
    else raise ArgumentError, "Could not find rate for #{rate_type}"
    end
  end

  def calculate_rate(default_percentage)
    self.full_rate.to_f * default_percentage
  end
##  COPIED FROM SPARC-REQUEST END ##
end
