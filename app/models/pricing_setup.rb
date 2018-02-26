# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

class PricingSetup < ApplicationRecord

  include SparcShard

  belongs_to :organization

  scope :current, -> (date) { where("effective_date <= ?", date).order("effective_date DESC").limit(1) }

  def rate_type(funding_source)
    case funding_source
    when 'college'       then self.college_rate_type
    when 'federal'       then self.federal_rate_type
    when 'foundation'    then self.foundation_rate_type
    when 'industry'      then self.industry_rate_type
    when 'investigator'  then self.investigator_rate_type
    when 'internal'      then self.internal_rate_type
    when 'unfunded'      then self.unfunded_rate_type
    else raise ArgumentError, "Could not find rate type for funding source #{funding_source}"
    end
  end

  def rate_type_percentage(type)
    case type
    when 'federal'   then  ( self.federal / 100 )
    when 'corporate' then  ( self.corporate / 100 )
    when 'member'    then  ( self.member / 100 )
    when 'other'     then  ( self.other / 100 )
    else 1.0
    end
  end

  def applied_percentage(rate_type)
    applied_percentage = case rate_type
    when 'federal' then self.federal
    when 'corporate' then self.corporate
    when 'other' then self.other
    when 'member' then self.member
    when 'full' then 100
    else raise ArgumentError, "Could not find applied percentage for rate type #{rate_type}"
    end

    applied_percentage = applied_percentage / 100.0 rescue nil

    return applied_percentage || 1.0
  end
end
