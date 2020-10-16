# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

class Sparc::Setting < SparcDbBase
  def self.preload_values
    # Cache settings for the current request thread for the current request
    RequestStore.store[:settings_map] ||= Setting.all.map{ |s| [s.key, { value: s.read_attribute(:value), data_type: s.data_type }] }.to_h
  end

  def self.get_value(key)
    if RequestStore.store[:settings_map] && RequestStore.store[:settings_map][key]
      converted_value(RequestStore.store[:settings_map][key][:value], RequestStore.store[:settings_map][key][:data_type])
    else
      Setting.find_by_key(key).value rescue nil
    end
  end

  def value
    Setting.converted_value(read_attribute(:value), self.data_type)
  end

  private

  def self.converted_value(val, data_type)
    case data_type
    when 'boolean'
      val == 'true'
    when 'json'
      begin
        JSON.parse(val.gsub("=>", ": "))
      rescue
        nil
      end
    else
      val
    end
  end
end
