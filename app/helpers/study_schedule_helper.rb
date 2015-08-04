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
