class ConvertDelayedJobHandlerToLongText < ActiveRecord::Migration[5.2]
  def change
    change_column :delayed_jobs, :handler, :longtext
  end
end
