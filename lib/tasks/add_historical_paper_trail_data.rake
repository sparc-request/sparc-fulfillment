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

namespace :data do
  desc 'Add historical "change set" data to paper trail records'
  task add_historical_paper_trail_changes: :environment do
    bar = ProgressBar.new(Version.count)

    Version.find_each do |version|
      begin
        next unless (version.object_changes.nil?) && (version.event != "destroy")

        changes = {}

        if version.event == "create"
          object = (version.next.try(:reify) or eval(version.item_type).with_deleted.find(version.item_id))

          object.attributes.each do |attribute_name, value|
            default = object.class.columns_hash[attribute_name].default
            if default
              changes[attribute_name] = [default, value]
            else
              next if value.nil?
              changes[attribute_name] = [nil, value]
            end
          end
        else
          #version is "update" event.
          object = version.reify
          new_object = (object.next_version or eval(version.item_type).with_deleted.find(version.item_id))

          object.attributes.each do |attribute_name, value|
            next unless value != new_object.attributes[attribute_name]
            changes[attribute_name] = [value, new_object.attributes[attribute_name]]
          end
        end

        ##Save it to column
        serialized = PaperTrail.serializer.dump(changes)
        version.object_changes = serialized
        version.save

        bar.increment! rescue nil

      rescue Exception => e
        puts "Error with #{version.inspect}, Message: #{e.message}"
        bar.increment! rescue nil
        next
      end
    end
  end
end
