#encoding: utf-8
class TasksController < ApplicationController
  layout 'tasks'
  def index
    @title = "任务中心"
    @user = User.find_by_id session[:user_id]
    if !@user.nil? && @user.types != User::TYPES[:ADMIN]
      @tasks = Task.list @user.id, @user.types
    else
      redirect_to root_url
    end
  end

  def show
    @user = User.find_by_id(session[:user_id])
    if @user.nil?
      redirect_to root_url
    else
      @task = Task.find_by_id(params[:id])
      if !@task.nil? && (@task.ppt_doer == @user.id || @task.checker == @user.id || @task.flash_doer == @user.id)
        @title = "任务详情-#{@task.name}"
        @task_tag_id = @task.task_tag.id
        @ppt_files = @task.accessories.where("types = '#{Accessory::TYPES[:PPT]}'").order("created_at")
        @flash_files = @task.accessories.where("types = '#{Accessory::TYPES[:FLASH]}'").order("created_at")
      else
        redirect_to :action => :index
      end
    end
  end

  #领取任务
  def assign_tasks
    user = User.find_by_id params[:user_id]
    Task.get_tasks user.id, user.types
    @tasks = Task.list user.id, user.types
    @info = {:notice => notice, :tasks => @tasks}
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
    p task
    @info = {:notice => notice, :task => task, :user_id => user.id, :status => status}
  end

  def uploadfile
    uploadfile = params[:file]
    @file_type = params[:file_type]
    @task = Task.find_by_id params[:task_id]
    @task_tag_id = @task.task_tag.id
    longness = nil
    file_type = nil
    file_url = "#{Rails.root}/public/accessories/task_tag_#{@task_tag_id}/task_#{@task.id}/#{@file_type}"
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
      p @task.id
      p @task.status
      @task = update_task_status @task.id, @task.status
      Accessory.create(:name => uploadfile.original_filename, :types => file_type,:task_id => @task.id,
      :status => Accessory::STATUS[:NO], :accessory_url => "/accessories/task_tag_#{@task_tag_id}/task_#{@task.id}/#{@file_type}/#{uploadfile.original_filename}", :longness => longness) if !longness.nil? || !file_type.nil?
      @ppt_files = @task.accessories.where("types = 'ppt'").order("created_at")
      @notice = "上传#{@file_type}成功!"
      @status = true
    else
      @notice = "没有上传文件!"
      @status = false
    end
  end

  #刷新任务数据
  def reload_tasks

  end
  #private
  #
  #def get_host_and_port
  #  @host_and_port = request.host_with_port
  #end
end
