#encoding: utf-8
class Task < ActiveRecord::Base
  belongs_to :task_tag
  has_many :accessories
  STATUS = {:NEW => 0, :WAIT_UPLOAD_PPT => 1, :WAIT_FIRST_CHECK => 2, :WAIT_PUB_FLASH => 3,
    :WAIT_ASSIGN_FLASH => 4, :WAIT_UPLOAD_FLASH => 5, :WAIT_PPT_DEAL => 6,
    :WAIT_SECOND_CHECK => 7, :WAIT_FINAL_CHECK => 8, :FINAL_CHECK_COMPLETE => 9}
  STATUS_NAME = {0 => "未领取", 1 => "待一次上传", 2 => "待一次质检", 3 => "待发布动画",
    4 => "待领取动画任务", 5 => "待上传动画", 6 => "待二次上传", 7 => "待二次质检",
    8 =>"待终检", 9 =>"终检完成"}
  TYPES = {:PPT => 0, :FLASH => 1}
  TYPES_NAME = {0 => "PPT制作", 1 => "动画制作"}

  IS_CALCULATE = {:YSE =>1,:NO => 0 }
  IS_UPLOAD_SOURCE = {:YES =>1,:NO => 0 }

  #获取用户相关的任务数据
  def self.list user_id,user_types
    if user_types == User::TYPES[:CHECKER]    #质检用户的任务数据
      @tasks = Task.where("checker=#{user_id} and status not in (#{Task::STATUS[:NEW]},#{Task::STATUS[:WAIT_UPLOAD_PPT]})")
    elsif user_types == User::TYPES[:PPT]     #PPT用户的任务数据
      @tasks = Task.where("ppt_doer=#{user_id} and status not in (#{Task::STATUS[:NEW]},#{Task::STATUS[:WAIT_ASSIGN_FLASH]},#{Task::STATUS[:WAIT_UPLOAD_FLASH]})")
    elsif user_types == User::TYPES[:FLASH]   #FLASH用户的任务数据
      @tasks = Task.where("flash_doer=#{user_id} and status in (#{Task::STATUS[:WAIT_UPLOAD_FLASH]},#{Task::STATUS[:WAIT_PPT_DEAL]},#{Task::STATUS[:WAIT_SECOND_CHECK]},#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]})")
    end
  end

  #领取任务
  def self.get_tasks user_id,user_types
    assign_task_num = 6  #默认分配任务的总数
    ppt_doer = nil
    flash_doer = nil
    if user_types == User::TYPES[:PPT] || user_types == User::TYPES[:FLASH]

      if user_types == User::TYPES[:PPT] #用户类型为PPT
        owner_tasks_sql = "status not in(#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]}) and ppt_doer = #{user_id}"
        wait_assign_tasks_sql = "status=#{Task::STATUS[:NEW]}"
        assigned_task_status = Task::STATUS[:WAIT_UPLOAD_PPT]
        ppt_doer = user_id
      else #用户类型为FLASH
        owner_tasks_sql = "status not in(#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]}) and flash_doer = #{user_id}"
        wait_assign_tasks_sql= "status=#{Task::STATUS[:WAIT_ASSIGN_FLASH]}"
        assigned_task_status = Task::STATUS[:WAIT_UPLOAD_FLASH]
        flash_doer = user_id
      end
      owner_tasks = Task.where owner_tasks_sql   #当前持有的任务
      assign_task_num = assign_task_num - owner_tasks.length
      wait_assign_tasks = Task.where wait_assign_tasks_sql
      count = 1
      wait_assign_tasks.each do |task|
        if count <= assign_task_num
          current_task = Task.find_by_id task.id
          if current_task.status != assigned_task_status
            time_now = Time.now #任务开始时间
            if !ppt_doer.nil?
              current_task.update_attributes(:status => assigned_task_status, :ppt_doer => user_id, :ppt_start_time => time_now)
            elsif !flash_doer.nil?
              current_task.update_attributes(:status => assigned_task_status, :flash_doer => user_id, :ppt_start_time => time_now)
            else
            end
          end
        else
        end
        count+=1
      end
    end
  end

  #统计PPT和FLASH领取，在领取后二十四内小时未提交的任务
  def count_abandon_tasks
    # Task.
  end  
end
