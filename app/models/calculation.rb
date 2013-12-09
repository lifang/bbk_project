#encoding: utf-8
class Calculation < ActiveRecord::Base
  IS_PAY = {:PAIED => true,:NO_PAY => false}
  IS_PAY_NAME = {true => '已付款', false => "未付款"}
  LONGNESS = {:FREQUENCY =>0,:SECONDS => 1}
  LONGNESS_NAME = {0 => '次数', 1 => '秒数'}

  def self.statistics_monthly_output #统计员工每月完成量
    month = Time.now.strftime("%Y-%m")
      Calculation.transaction do
      #质检人员统计
      checkers = Task.find_by_sql("SELECT count(*) shuliang,checker from tasks where status in (#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]})
and is_calculate = #{Task::IS_CALCULATE[:NO]} and checker is not null GROUP BY checker")
      checkers.each do |checker|
        checker_count = checker.shuliang
        checker_id = checker.checker
        Calculation.create(:user_id => checker_id,:month => month,:time => checker_count,
          :is_pay => "#{Calculation::IS_PAY[:NO_PAY]}",:longness => "#{Calculation::LONGNESS[:FREQUENCY]}" )
      end
      #ppt人员统计
      ppt_doers = Task.find_by_sql("SELECT count(*) shuliang,ppt_doer from tasks
where status in (#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]})
and is_calculate = #{Task::IS_CALCULATE[:NO]} and ppt_doer is not null GROUP BY ppt_doer")
      ppt_doers.each do |ppt_doer|
        ppt_count = ppt_doer.shuliang
        ppt_doer_id = ppt_doer.ppt_doer
        Calculation.create(:user_id => ppt_doer_id,:month => month,:time => ppt_count,:is_pay => "#{Calculation::IS_PAY[:NO_PAY]}",:longness => "#{Calculation::LONGNESS[:FREQUENCY]}" )
      end
      #flash人员统计
      flash_doers = Task.find_by_sql("select sum(accessories.longness) seccondes,tasks.flash_doer
from tasks inner JOIN accessories on tasks.id = accessories.task_id
    where tasks.status in (#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]})
and tasks.is_calculate = #{Task::IS_CALCULATE[:NO]}
and accessories.types = #{Accessory::TYPES[:FLASH]} and accessories.status = #{Accessory::STATUS[:YES]} GROUP BY tasks.flash_doer")
      flash_doers.each do |flash_doer|
        flash_sum = flash_doer.seccondes
        flash_doer_id = flash_doer.flash_doer
        Calculation.create(:user_id => flash_doer_id,:month => month,:time => flash_sum,:is_pay => "#{Calculation::IS_PAY[:NO_PAY]}",:longness => 1 )
      end
      tasks = Task.find_by_sql("SELECT * from tasks where status in (#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]}) and is_calculate = #{Task::IS_CALCULATE[:NO]}")
      tasks.each do |task|
        task.update_attributes(:is_calculate =>"#{Task::IS_CALCULATE[:YSE]}")
      end
    end
  end
end
