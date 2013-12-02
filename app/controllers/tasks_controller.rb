#encoding: utf-8
class TasksController < ApplicationController
  layout 'tasks'
  def index
    @title = "任务中心"
    user_id = session[:user_id]
    @user = User.find_by_id(user_id)
    if !@user.nil?
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
        @ppt_files = @task.accessories.where("types = 'ppt'").order("created_at")
        @ppt_files.each do |ppt|
          p ppt
        end
      else
        redirect_to :action => :index
      end
    end
  end

  def assign_tasks
    user = User.find_by_id params[:user_id]
    Task.get_tasks user.id, user.types
    @tasks = Task.list user.id, user.types
    @info = {:notice => notice, :tasks => @tasks}
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
