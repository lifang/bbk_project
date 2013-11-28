#encoding: utf-8
class TasksController < ApplicationController
  layout 'tasks'
  def index
    @title = "任务中心"
    user_id = session[:user_id]
    @user = User.find(user_id)
    if !@user.nil?
      @tasks = Task.list @user.id, @user.types
    end
  end

  def show
    @task = Task.find(params[:id])
    @task_tag_id = @task.task_tag.id
    #@host_and_port = get_host_and_port
    #p @host_and_port
    @ppt_files = @task.accessories.where("types = 'ppt'").order("created_at")
    @ppt_files.each do |ppt|
      p ppt
    end
    @title = "任务详情-#{@task.name}"
    user_id = session[:user_id]
    @user = User.find(user_id)
  end

  def assign_tasks
    user = User.find params[:user_id]
    Task.get_tasks user.id, user.types
    @tasks = Task.list user.id, user.types
    @info = {:notice => notice, :tasks => @tasks}
  end

  def uploadfile
    uploadfile = params[:file]
    @file_type = params[:file_type]
    @task = Task.find params[:task_id]
    @task_tag_id = @task.task_tag.id
    longness = nil
    file_type = nil
    file_url = "#{Rails.root}/public/accessories/task_tag_#{@task_tag_id}/task_#{@task.id}/#{@file_type}"
    @user = User.find params[:user_id]
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
      update_task_status @task.id, @task.status
      Accessory.create(:name => uploadfile.original_filename, :types => file_type,:task_id => @task.id,
      :status => Accessory::STATUS[:NO], :accessory_url => "/accessories/task_tag_#{@task_tag_id}/task_#{@task.id}/#{@file_type}/#{uploadfile.original_filename}", :longness => longness) if !longness.nil? || !file_type.nil?
      @ppt_files = @task.accessories.where("types = 'ppt'").order("created_at")
      @notice = "上传#{@file_type}成功!"
    else
      @notice = "没有上传文件!"
    end
  end
  #private
  #
  #def get_host_and_port
  #  @host_and_port = request.host_with_port
  #end
end
