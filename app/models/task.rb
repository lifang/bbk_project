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

  CONFIG = {:TASK_LIMIT => 3, :RELEASE_HOURS => 24, :OVER_TIME_HOURS => 48}

  #获取用户相关的任务数据
  def self.list user_id,user_types
    if user_types == User::TYPES[:CHECKER]    #质检用户的任务数据
      @tasks = Task.where("checker=#{user_id} and status not in (#{Task::STATUS[:NEW]},#{Task::STATUS[:WAIT_UPLOAD_PPT]})")
    elsif user_types == User::TYPES[:PPT]     #PPT用户的任务数据
      # @tasks = Task.where("ppt_doer=#{user_id} and status not in (#{Task::STATUS[:NEW]},#{Task::STATUS[:WAIT_ASSIGN_FLASH]},#{Task::STATUS[:WAIT_UPLOAD_FLASH]})")
      @tasks = Task.where("ppt_doer=#{user_id} and status not in (#{Task::STATUS[:NEW]})")
    elsif user_types == User::TYPES[:FLASH]   #FLASH用户的任务数据
      @tasks = Task.where("flash_doer=#{user_id} and status in (#{Task::STATUS[:WAIT_UPLOAD_FLASH]},#{Task::STATUS[:WAIT_PPT_DEAL]},#{Task::STATUS[:WAIT_SECOND_CHECK]},#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]})")
    end
  end

  #领取任务
  def self.get_tasks user_id,user_types
    assign_task_num = Task::CONFIG[:TASK_LIMIT]  #最大可获取任务数
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
      count = 0
      if assign_task_num > 0
        wait_assign_tasks.each do |task|
          if count < 1
            current_task = Task.find_by_id task.id
            if current_task.status != assigned_task_status
              time_now = Time.now() #任务开始时间
              if user_types == User::TYPES[:PPT] #用户类型为PPT
                if current_task.update_attributes(:status => assigned_task_status, :ppt_doer => user_id, :ppt_start_time => time_now)
                  count+=1
                end
              elsif user_types == User::TYPES[:FLASH] #用户类型为FLASH
                if current_task.update_attributes(:status => assigned_task_status, :flash_doer => user_id, :flash_start_time => time_now)
                  count+=1
                end
              end
            end
          end
        end
        if count > 0
          status = "true"
        else
          status = "false"
        end
      else
        status = "limit"
      end
    end
    status
  end

  #统计PPT和FLASH领取，在领取后二十四内小时未提交的任务
  def self.count_abandon_tasks
    time_now = Time.now()
    time_limit = Task::CONFIG[:RELEASE_HOURS] * 60
    abandon_tasks = Task.find_by_sql("select id, name, status, ppt_doer, flash_doer, checker, updated_at, 
      (TIMESTAMPDIFF(minute, updated_at, now())-480) as plus from tasks t where status in (#{Task::STATUS[:WAIT_UPLOAD_PPT]},#{Task::STATUS[:WAIT_UPLOAD_FLASH]}) 
       and (TIMESTAMPDIFF(minute, updated_at, now())-480) >=#{time_limit}")
    abandon_tasks.each do |task|
      current_task = Task.find_by_id task.id
      if task.status == Task::STATUS[:WAIT_UPLOAD_PPT]
        user = User.find_by_id task.ppt_doer
        abandon_task_types = AbandonTask::TYPES[:PPT]
        current_task.update_attributes(:status => Task::STATUS[:NEW], :ppt_doer => nil)
      elsif task.status == Task::STATUS[:WAIT_UPLOAD_FLASH]
        user = User.find_by_id task.flash_doer
        abandon_task_types = AbandonTask::TYPES[:FLASH]
        current_task.update_attributes(:status => Task::STATUS[:WAIT_ASSIGN_FLASH], :flash_doer => nil)
      else
        user = nil
      end
      AbandonTask.create(:task_id => task.id, :types => abandon_task_types, :user_id => user.id)    
    end      
  end 
  
  #获取PPT和FLASH的统计信息
  def self.going_and_over_time_task user_id, user_types
    time_limit = Task::CONFIG[:OVER_TIME_HOURS] * 60
    if user_types == User::TYPES[:PPT] || user_types == User::TYPES[:FLASH]
        if user_types == User::TYPES[:PPT]
          going_tasks_sql = "status not in(#{Task::STATUS[:WAIT_FINAL_CHECK]},
            #{Task::STATUS[:FINAL_CHECK_COMPLETE]}) and ppt_doer = #{user_id}"
          over_time_tasks_sql = "ppt_doer = #{user_id} and status not in 
            (#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]}) 
            and (TIMESTAMPDIFF(minute, created_at, now())-480) >= #{time_limit}"
        elsif user_types == User::TYPES[:FLASH]
          going_tasks_sql = "status not in(#{Task::STATUS[:WAIT_FINAL_CHECK]},
            #{Task::STATUS[:FINAL_CHECK_COMPLETE]}) and flash_doer = #{user_id}"
          over_time_tasks_sql = "flash_doer = #{user_id} and status not in 
            (#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]}) 
            and (TIMESTAMPDIFF(minute, created_at, now())-480) >=#{time_limit}"
        end  
        goning_tasks = Task.where going_tasks_sql
        over_time_tasks = Task.where over_time_tasks_sql
    end 
    @return = {:goning_tasks => goning_tasks, :over_time_tasks => over_time_tasks}   
  end

  #显示质检的统计信息
  def self.checker_wait_task user_id
    wait_first_check_tasks = Task.where("status = #{Task::STATUS[:WAIT_FIRST_CHECK]} and checker = #{user_id}")
    wait_second_check_tasks = Task.where("status = #{Task::STATUS[:WAIT_SECOND_CHECK]} and checker = #{user_id}")
    wait_final_check_tasks = Task.where("status = #{Task::STATUS[:WAIT_FINAL_CHECK]} and checker = #{user_id}")
    @return = {:wait_first_check_tasks => wait_first_check_tasks, :wait_second_check_tasks => wait_second_check_tasks,
      :wait_final_check_tasks => wait_final_check_tasks}
  end
end
