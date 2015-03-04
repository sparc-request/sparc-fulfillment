module Features

  module TaskHelpers

    def create_tasks(count=1)
      create_list(:task, count)
    end
  end
end