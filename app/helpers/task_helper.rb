module TaskHelper

  def format_reschedule task_id
    html = '-'
    icon = raw content_tag(:i, '', class: "glyphicon glyphicon-calendar")
    html = raw content_tag(:a, raw(icon), class: 'task-reschedule', href: 'javascript:void(0)', task_id: task_id)

    html
  end

  def format_checkbox task
    html = '-'
    html = raw content_tag(:input, '', class: 'complete', name: 'complete', type: 'checkbox', task_id: task.id, checked: task.complete? ? "checked" : nil)

    html
  end

  def format_task_type task
    task_type = task.assignable_type
    task_type += " (#{task.assignable.service_name})" if task_type == "Procedure"

    task_type
  end

  def format_task_protocol_id task
    case task.assignable_type
    when 'Procedure'
      Procedure.find(task.assignable_id).protocol.srid
    else
      '-'
    end
  end

  def format_due_date task
    due_date = task.due_at
    if task.complete or (due_date - 7.days) > Time.now # task is complete or due_date is greater than 7 days away
      format_date(due_date)
    elsif due_date <= Time.now # due date has passed
      content_tag(:span, class: "overdue-task"){"#{format_date(due_date)} - PAST DUE"}
    else # due date is within 7 days
      content_tag(:span, class: "overdue-task"){format_date(due_date)}
    end
  end
end
