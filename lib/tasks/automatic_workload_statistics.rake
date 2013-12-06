#encoding: utf-8
namespace :wage_statistics do
  desc "Statistics amount each month to complete"
  task(:automatic_workload_statistics => :environment) do
    Calculation.statistics_monthly_output
  end
end