#encoding: utf-8
class Task < ActiveRecord::Base
  belongs_to :task_tag
  STATUS = {:NEW => 0, :WAIT_UPLOAD_PPT => 1, :WAIT_FIRST_CHECK => 2, :WAIT_PUB_FLASH => 3,
            :WAIT_ASSIGN_FLASH => 4, :WAIT_UPLOAD_FLASH => 5, :WAIT_PPT_DEAL => 6,
            :WAIT_SECOND_CHECK => 7, :WAIT_FINAL_CHECK => 8, :FINAL_CHECK_COMPLETE => 9}
  STATUS_NAME = {0 => "未领取", 1 => "待一次上传", 2 => "待一次质检", 3 => "待发布动画",
                 4 => "待领取动画任务", 5 => "待上传动画", 6 => "待二次上传", 7 => "待二次质检",
                 8 =>"待终检", 9 =>"终检完成"}
  TYPES = {:PPT => 0, :FLASH => 1}
  TYPES_NAME = {0 => "PPT制作", 1 => "动画制作"}

  #获取用户相关的任务数据
  def self.list user_id,user_types
    if user_types == User::TYPES[:CHECKER]    #质检用户的任务数据
      @tasks = Task.where("checker=#{user_id} and status in (#{Task::STATUS[:WAIT_FIRST_CHECK]},#{Task::STATUS[:WAIT_SECOND_CHECK]},#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]})")
    elsif user_types == User::TYPES[:PPT]     #PPT用户的任务数据
      @tasks = Task.where("ppt_doer=#{user_id} and status not in (#{Task::STATUS[:NEW]},#{Task::STATUS[:WAIT_ASSIGN_FLASH]},#{Task::STATUS[:WAIT_UPLOAD_FLASH]})")
    elsif user_types == User::TYPES[:FLASH]   #FLASH用户的任务数据
      @tasks = Task.where("flash_doer=#{user_id} and status in (#{Task::STATUS[:WAIT_UPLOAD_FLASH]},#{Task::STATUS[:WAIT_PPT_DEAL]},#{Task::STATUS[:WAIT_SECOND_CHECK]},#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]})")
    end
  end

  #领取任务
  def self.get_tasks user_id,user_types
    time_now = Time.now #任务开始时间
    assign_task_num = 5  #默认分配任务的总数
    if user_types == User::TYPES[:PPT]
      #当前持有的任务
      owner_tasks = Task.where("status=#{Task::STATUS[:WAIT_UPLOAD_PPT]} and ppt_doer = #{user_id}")
      assign_task_num = assign_task_num-owner_tasks.length
      undeal_tasks = Task.where "status=#{Task::STATUS[:NEW]}"
      count = 1
      undeal_tasks.each do |task|
        if count <= assign_task_num
          current_task = Task.find task.id
          if current_task.status != Task::STATUS[:WAIT_UPLOAD_PPT]
            current_task.update_attributes(:status => Task::STATUS[:WAIT_UPLOAD_PPT], :ppt_doer => user_id, :ppt_start_time => time_now)
          end
          count+=1
        end
      end if(!undeal_tasks.nil? || undeal_tasks.length != 0)
    elsif user_types == User::TYPES[:FLASH]
      #当前持有的任务
      owner_tasks = Task.count.where("status=#{Task::STATUS[:WAIT_UPLOAD_FLASH]} and flash_doer = #{user_id}")
      assign_task_num = assign_task_num-owner_tasks.length
      undeal_tasks = Task.where "status=#{Task::STATUS[:WAIT_ASSIGN_FLASH]}"
      count = 0
      undeal_tasks.each do |task|
        if count <= assign_task_num
          current_task = Task.find task.id
          if current_task.status != Task::STATUS[:WAIT_UPLOAD_FLASH]
            task.update_attributes(:status => Task::STATUS[:WAIT_UPLOAD_FLASH], :flash_doer => user_id,:flash_start_time => time_now)
          end
          count+=1
        end
      end if(!undeal_tasks.nil? || undeal_tasks.length != 0)
    else
      undeal_tasks = nil
    end
    undeal_tasks
  end
end
