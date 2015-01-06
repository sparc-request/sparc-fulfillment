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
end