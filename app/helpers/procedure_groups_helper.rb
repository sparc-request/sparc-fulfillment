module ProcedureGroupsHelper
  def format_time(time)
    return if time.nil?
    time.strftime('%I:%M %p')

  end
end
