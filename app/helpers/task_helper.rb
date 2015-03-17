module TaskHelper

  def format_reschedule(task_id)
    html = '-'
    icon = raw content_tag(:i, '', class: "glyphicon glyphicon-calendar")
    html = raw content_tag(:a, raw(icon), class: 'task-reschedule', href: '#', task_id: task_id)

    html
  end

  def format_checkbox(task_id)
    html = '-'
    html = raw content_tag(:input, '', class: 'task-complete', name: 'is_complete', type: 'checkbox', task_id: task_id)

    html
  end

  def user_name(id)
    user = User.find(id)

    user.full_name
  end
end