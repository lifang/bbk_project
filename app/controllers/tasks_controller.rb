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
    @user = User.find(session[:user_id])
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
      p @task.id
      p @task.status
      @task = update_task_status @task.id, @task.status
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

  #任务包ppt列表
  def tasktag_pptlist
    @task_tag = TaskTag.find_by_id( params[:task_tag_id])
#    @task_pptlist = Task.where(:task_tag_id => params[:task_tag_id])
    @task_pptlist = Task.find_by_sql("SELECT tasks.id,tasks.name task_name,usersx.user_pptname,usersx.user_flashname,usersx.user_check,  tasks.status  from tasks left JOIN
(SELECT user1.id,user1.user_name user_pptname,user2.user_name user_flashname,user3.user_name user_check FROM
(SELECT t1.id id, t1.name task_name, u1.name user_name from tasks t1,users u1 where t1.ppt_doer = u1.id ) user1,
(SELECT t2.id id, t2.name task_name, u2.name user_name from tasks t2,users  u2 where t2.flash_doer = u2.id ) user2,
(SELECT t3.id id, t3.name task_name, u3.name user_name from tasks t3,users  u3 where t3.checker = u3.id ) user3
where user1.id = user2.id and user1.id = user3.id) usersx on tasks.id = usersx.id where tasks.task_tag_id = #{params[:task_tag_id]}")
  end
end
