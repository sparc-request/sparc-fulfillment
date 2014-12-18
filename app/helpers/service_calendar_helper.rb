module ServiceCalendarHelper
  def create_left_arrow arm, cur_page=1
    # previous_page
    # disabled = cur_page == 1 ? true : false
    # button_tag '', id: "left-arrow-#{arm.id}", class: 'btn btn-primary glyphicon glyphicon-arrow-left', disabled: disabled
  end

  def disable_right_arrow? arm, cur_page
    return true
  end
end
