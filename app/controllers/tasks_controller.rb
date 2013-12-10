#encoding: utf-8
class TasksController < ApplicationController
  layout 'tasks'
  def index
    @title = "任务中心"
    @user = User.find_by_id session[:user_id]
    p @user
    time_limit = Task::CONFIG[:RELEASE_HOURS] * 60
    if !@user.nil? && @user.types != User::TYPES[:ADMIN]
      @tasks = Task.list @user.id, @user.types
      if @user.types == User::TYPES[:PPT] || @user.types == User::TYPES[:FLASH]
        result = Task.going_and_over_time_task @user.id, @user.types
        @goning_tasks = result[:goning_tasks]
        @over_time_tasks = result[:over_time_tasks]
        p @goning_tasks
        p @over_time_tasks
      elsif @user.types == User::TYPES[:CHECKER]
        result = Task.checker_wait_task @user.id
        @wait_first_check_tasks = result[:wait_first_check_tasks]
        @wait_second_check_tasks = result[:wait_second_check_tasks]
        @wait_final_check_tasks = result[:wait_final_check_tasks]
      else
      end      
    else
      redirect_to root_url
    end
  end

  def show
    @user = User.find_by_id session[:user_id]
    @task = Task.find_by_id params[:id]
    if @user.nil?
      redirect_to root_url
    else
      @task = Task.find_by_id(params[:id])
      if !@task.nil? && (@task.ppt_doer == @user.id || @task.checker == @user.id || @task.flash_doer == @user.id)
        @title = "任务详情-#{@task.name}"
        @task_tag_id = @task.task_tag.id
        case @user.types
          when User::TYPES[:PPT]
            @ppt_files = @task.accessories.where("types = '#{Accessory::TYPES[:PPT]}'").order("created_at")
            @flash_files = @task.accessories.where("types = '#{Accessory::TYPES[:FLASH]}'").order("created_at")
            @left_reciver = User.find_by_id @task.checker
            @right_reciver = User.find_by_id @task.flash_doer
          when User::TYPES[:FLASH]
            @flash_files = @task.accessories.where("types = '#{Accessory::TYPES[:FLASH]}'").order("created_at")
            @right_reciver = User.find_by_id @task.ppt_doer
          when User::TYPES[:CHECKER]
            @ppt_files = @task.accessories.where("types = '#{Accessory::TYPES[:PPT]}'").order("created_at")
            @left_reciver = User.find_by_id @task.ppt_doer
        end
      else
        redirect_to :action => :index
      end
    end
  end

  #领取任务
  def assign_tasks
    @user = User.find_by_id params[:user_id]
    Task.get_tasks @user.id, @user.types
    tasks = Task.list @user.id, @user.types
    @info = {:notice => notice, :tasks => tasks}
  end

  #审核任务
  def verify_task
    status = -1
    user = User.find_by_id params[:user_id]
    task = Task.find_by_id params[:task_id]
    if !user.nil?
      if user.types == User::TYPES[:CHECKER]
        if task.nil?
          notice = "非法操作:任务不存在"
          status = -1
        else
          if task.checker == user.id
            if task.status == Task::STATUS[:WAIT_FIRST_CHECK]
              task.update_attributes(:status => Task::STATUS[:WAIT_PUB_FLASH])
              status = 0
            elsif task.status == Task::STATUS[:WAIT_SECOND_CHECK]
              task.update_attributes(:status => Task::STATUS[:WAIT_FINAL_CHECK])
              ppt_files = task.accessories.where("types=#{Accessory::TYPES[:PPT]}").order("created_at")
              ppt_files.last.update_attributes(:status => "#{Accessory::STATUS[:YES]}")
              status = 0
            else
              status = -1
            end
          else
            notice = "非法操作:该任务不是属于当前用户"
            status = -1
          end
        end
      else
        notice = "非法操作:用户没有权限"
        status = -1
      end
    else
      notice = "非法操作:用户不存在"
      status = -1
    end
    @info = {:notice => notice, :task => task, :user_id => user.id, :status => status}
  end

  #上传文件PPT、flash
  def uploadfile
    checkers = User.where("status = #{User::STATUS[:NORMAL]} and types = #{User::TYPES[:CHECKER]}")
    @task = Task.find_by_id params[:task_id]
    if checkers.nil? || checkers.length == 0 
      @notice = "没有质检，不能上传文件!"
      @status = false
    else  
      uploadfile = params[:file]
      @file_type = params[:file_type]
      task = Task.find_by_id params[:task_id]
      @task_tag_id = task.task_tag.id
      longness = nil
      file_type = nil
      file_url = "#{Rails.root}/public/accessories/task_tag_#{@task_tag_id}/task_#{task.id}/#{@file_type}"
      @user = User.find_by_id params[:user_id]
      if !uploadfile.nil?
        if @file_type == "ppt"
          longness = 1
          file_type = Accessory::TYPES[:PPT]
        elsif @file_type == "flash"
          longness = 10
          file_type = Accessory::TYPES[:FLASH]
        else
        end
        upload uploadfile, file_url
        @task = update_task_status task.id, task.status, @user.types
        Accessory.create(:name => uploadfile.original_filename, :types => file_type,:task_id => @task.id,
          :status => Accessory::STATUS[:NO], :accessory_url => "/accessories/task_tag_#{@task_tag_id}/task_#{@task.id}/#{@file_type}/#{uploadfile.original_filename}", :longness => longness) if !longness.nil? || !file_type.nil?
        @ppt_files = @task.accessories.where("types = #{Accessory::TYPES[:PPT]}").order("created_at")
        @flash_files = @task.accessories.where("types = #{Accessory::TYPES[:FLASH]}").order("created_at")
        case @user.types
          when User::TYPES[:PPT]
            @left_reciver = User.find_by_id @task.checker
            @right_reciver = User.find_by_id @task.flash_doer
          when User::TYPES[:FLASH]
            @right_reciver = User.find_by_id @task.ppt_doer
        end
        @notice = "上传#{@file_type}成功!"
        @status = true
      else
        @notice = "没有上传文件!"
        @status = false
      end
    end  
  end

  #上传flash源码
  def uploadfile_flash_source_file
    uploadfile = params[:file]
    task = Task.find_by_id params[:task_id]
    task_tag_id = task.task_tag.id
    user = User.find_by_id params[:user_id]
    file_url = "#{Rails.root}/public/accessories/task_tag_#{task_tag_id}/task_#{task.id}/fla"
    if !uploadfile.nil?
      upload uploadfile, file_url
      task.update_attributes(:source_url => "/accessories/task_tag_#{task_tag_id}/task_#{task.id}
        /fla/#{uploadfile.original_filename}", :is_upload_source => Task::IS_UPLOAD_SOURCE[:YES] )
      @notice = "上传完成!"
      @status = true
      @task = task
    else
      @notice = "没有上传文件!"
      @status = false 
    end  
  end  

  #发布动画任务
  def publish_flash_task
    uploadfile = params[:file]
    @task = Task.find_by_id params[:task_id]
    @task_tag_id = @task.task_tag.id
    file_url = "#{Rails.root}/public/accessories/task_tag_#{@task_tag_id}/task_#{@task.id}/origin"
    @user = User.find_by_id params[:user_id]
    if @user.types == User::TYPES[:PPT]
      if !uploadfile.nil?
        upload uploadfile, file_url
        @task = update_task_status @task.id, @task.status, @user.types
        @task.update_attributes(:origin_flash_url=>"/accessories/task_tag_#{@task_tag_id}/task_#{@task.id}/origin/#{uploadfile.original_filename}")
        @notice = "FLASH任务发布成功!"
        @status = true
      else
        @notice = "没有上传文件!"
        @status = false
      end
    else
      @notice = "该用户没有权限发布任务!"
      @status = false
    end
  end

  #刷新任务数据
  def reload_tasks
    @user = User.find_by_id session[:user_id]
    if !@user.nil?
      @tasks = Task.list @user.id, @user.types
    else
      @task = nil
    end
    @task
  end

  #任务包ppt列表
  def tasktag_pptlist
    @task_tag = TaskTag.find_by_id( params[:task_tag_id])
    @task_pptlist = Task.find_by_sql("SELECT tasks.id,tasks.name task_name,usersx.user_pptname,usersx.user_flashname,usersx.user_check,  tasks.status  from tasks left JOIN
(SELECT user1.id,user1.user_name user_pptname,user2.user_name user_flashname,user3.user_name user_check FROM
(SELECT t1.id id, t1.name task_name, u1.name user_name from tasks t1,users u1 where t1.ppt_doer = u1.id ) user1,
(SELECT t2.id id, t2.name task_name, u2.name user_name from tasks t2,users  u2 where t2.flash_doer = u2.id ) user2,
(SELECT t3.id id, t3.name task_name, u3.name user_name from tasks t3,users  u3 where t3.checker = u3.id ) user3
where user1.id = user2.id and user1.id = user3.id) usersx on tasks.id = usersx.id where tasks.task_tag_id = #{params[:task_tag_id]}")
  end
end
