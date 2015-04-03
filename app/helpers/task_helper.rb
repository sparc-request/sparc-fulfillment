module TaskHelper

  def format_reschedule(task_id)
    html = '-'
    icon = raw content_tag(:i, '', class: "glyphicon glyphicon-calendar")
    html = raw content_tag(:a, raw(icon), class: 'task-reschedule', href: '#', task_id: task_id)

    html
  end

  def format_checkbox(task)
    html = '-'
    html = raw content_tag(:input, '', class: 'complete', name: 'complete', type: 'checkbox', task_id: task.id, checked: task.complete? ? "checked" : nil)

    html
  end
end
