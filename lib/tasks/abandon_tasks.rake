#encoding: utf-8
namespace :drop_task_records do
  desc "take records  about task who droped"
  task(:abandon_tasks => :environment) do
    Task.count_abandon_tasks
  end
end