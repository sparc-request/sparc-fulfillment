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

module StudyScheduleManagementHelper
  def move_to_position_options_for(selected)
    selected.arm.visit_groups.where.not(id: selected.id).map do |visit_group|
      ["Before " + visit_name_with_day(visit_group), visit_group.position < selected.position ? visit_group.position : visit_group.position - 1]
    end << ["Add as last", selected.arm.visit_groups.size]
  end

  def insert_to_position_options(visit_groups)
    visit_groups.map do |visit_group|
      ["Before " + visit_name_with_day(visit_group), visit_group.position]
    end << ["Add as last", nil]
  end

  def edit_visit_options(visit_groups)
    visit_groups.map do |visit_group|
      [visit_name_with_day(visit_group), visit_group.id]
    end
  end

  private

  def visit_name_with_day(visit_group)
    visit_group.name + (!visit_group.day.nil? ? " (Day #{visit_group.day})" : "")
  end
end
