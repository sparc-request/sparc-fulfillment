module ServiceCalendarHelper
  def glyph_class line_item
    count = Visit.where("line_item_id = #{line_item.id} and research_billing_qty = 0 and insurance_billing_qty = 0").count
    if count == 0
      'glyphicon-remove'
    else
      'glyphicon-ok'
    end
  end

  def set_check line_item
    count = Visit.where("line_item_id = #{line_item.id} and research_billing_qty = 0 and insurance_billing_qty = 0").count
    if count == 0
      return false
    else
      return true
    end
  end

  def visits_select_options arm, cur_page=1
    num_pages = (arm.visit_count / Visit.per_page.to_f).ceil
    arr = []

    num_pages.times do |page|
      beginning_visit = (page * Visit.per_page) + 1
      ending_visit = (page * Visit.per_page + Visit.per_page)
      ending_visit = ending_visit > arm.visit_count ? arm.visit_count : ending_visit

      option = ["Visits #{beginning_visit} - #{ending_visit} of #{arm.visit_count}", page + 1, :style => "font-weight:bold;"]
      arr << option

      (beginning_visit..ending_visit).each do |y|
        arr << ["- #{arm.visit_groups[y - 1].name}".html_safe, "#{arm.visit_groups[y - 1].id}", :parent_page => page + 1]
      end
    end

    options_for_select(arr, cur_page)
  end

  def build_visits_select arm, page
    select_tag "visits_select_for_#{arm.id}", visits_select_options(arm, page), class: 'visit_dropdown form-control', :'data-arm_id' => "#{arm.id}", page: page
  end

  def on_current_page? current_page, visit_group
    if visit_group.position % Visit.per_page != 0
      destination_page = (visit_group.position / Visit.per_page) + 1
    else
      destination_page = visit_group.position / Visit.per_page
    end
    if destination_page == current_page.to_i
      return true
    else
      return false
    end
  end
end
