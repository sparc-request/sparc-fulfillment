module ServiceCalendarHelper
  def glyph_class obj
    count = obj.visits.where("research_billing_qty = 0 and insurance_billing_qty = 0").count
    if count == 0
      'glyphicon-remove'
    else
      'glyphicon-ok'
    end
  end

  def set_check obj
    count = obj.visits.where("research_billing_qty = 0 and insurance_billing_qty = 0").count
    if count == 0
      return false
    else
      return true
    end
  end

  def visits_select_options arm, cur_page=1
    per_page = Visit.per_page
    visit_count = arm.visit_count
    visit_group_names = arm.visit_groups.map(&:name)
    num_pages = (visit_count / Visit.per_page.to_f).ceil
    arr = []

    num_pages.times do |page|
      beginning_visit = (page * per_page) + 1
      ending_visit = (page * per_page + per_page)
      ending_visit = ending_visit > visit_count ? visit_count : ending_visit

      option = ["Visits #{beginning_visit} - #{ending_visit} of #{visit_count}", page + 1, class: "title", :page => page + 1]
      arr << option

      (beginning_visit..ending_visit).each do |y|
        arr << ["&nbsp;&nbsp; - #{visit_group_names[y - 1]}".html_safe, "#{visit_group_names[y - 1]}", :page => page + 1]
      end
    end

    options_for_select(arr, cur_page)
  end

  def build_visits_select arm, page
    select_tag "visits_select_for_#{arm.id}", visits_select_options(arm, page), class: 'visit_dropdown form-control selectpicker', :'data-arm_id' => "#{arm.id}", page: page
  end

  def on_current_page? current_page, visit_group
    destination_page = visit_group.position / Visit.per_page
    if visit_group.position % Visit.per_page != 0
      destination_page += 1
    end
    destination_page == current_page.to_i
  end
end
