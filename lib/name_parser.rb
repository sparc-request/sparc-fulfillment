# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

class NameParser
  def initialize(name)
    @name = name
  end

  def parse
    # return false if @name is not a String
    return false unless @name.is_a?(String)

    name_hash = {:first_name => nil, :middle_initial => nil, :last_name => nil}
    if @name.match(/,/)
      parts = @name.split(',')
      name_hash[:last_name] = parts[0]
      first_and_middle = parts[1].split

      if first_and_middle[1] && first_and_middle[1].size > 2
       name_hash[:first_name] = first_and_middle.join(' ')
      else
       name_hash[:first_name] = first_and_middle[0]
       name_hash[:middle_initial] = first_and_middle[1].first if first_and_middle[1]
      end
    else
      parts = @name.split
      name_hash[:first_name] = parts[0]

      if parts.size == 3
        if parts[1].size > 2
          name_hash[:first_name] += parts[1]
        else
          name_hash[:middle_initial] = parts[1].first if parts[1]
        end
      end

      name_hash[:last_name] = parts.size==3 ? parts[2] : parts[1]
    end

    # return false if all of the values are empty (nil, "")
    return false unless name_hash.values.any?{|x| x.present?}

    # default return the name hash
    name_hash
  end
end
