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

module StudyScheduleHelper

  def glyph_class obj
    count = obj.visits.where("research_billing_qty = 0 and insurance_billing_qty = 0").count
    count == 0 ? 'glyphicon-remove' : 'glyphicon-ok'
  end

  def set_check obj
    count = obj.visits.where("research_billing_qty = 0 and insurance_billing_qty = 0").count
    count != 0
  end

  def visits_select_options arm, cur_page=1
    per_page = Visit.per_page
    visit_count = arm.visit_count
    num_pages = (visit_count / per_page.to_f).ceil
    arr = []

    num_pages.times do |page|
      beginning_visit = (page * per_page) + 1
      ending_visit = (page * per_page + per_page)
      ending_visit = ending_visit > visit_count ? visit_count : ending_visit

      option = ["Visits #{beginning_visit} - #{ending_visit} of #{visit_count}", page + 1, class: "title", :page => page + 1]
      arr << option

      (beginning_visit..ending_visit).each do |y|
        arr << ["&nbsp;&nbsp; - #{arm.visit_groups[y - 1].name}".html_safe, "#{arm.visit_groups[y - 1].id}", :page => page + 1] if arm.visit_groups.present?
      end
    end

    options_for_select(arr, cur_page)
  end

  def build_visits_select arm, page
    select_tag "visits_select_for_#{arm.id}", visits_select_options(arm, page), class: 'visit_dropdown form-control selectpicker', :'data-arm_id' => "#{arm.id}", page: page
  end

  def on_current_page? current_page, position
    destination_page = position / Visit.per_page
    if position % Visit.per_page != 0
      destination_page += 1
    end

    destination_page == current_page.to_i
  end

  def create_line_items_options page_hash
    options = []
    page_hash.each do |arm_id, page|
      arm = Arm.find(arm_id)
      options << ["#{arm.name}", "#{arm_id} #{page}"]
    end

    options_for_select(options)
  end
end
