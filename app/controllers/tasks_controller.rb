#encoding: utf-8
class TasksController < ApplicationController
  layout 'tasks'
  def index
    session[:user_id] = 3
    @title = "任务中心"
    user_id = session[:user_id]
    @user = User.find(user_id)
    if !@user.nil?
      @tasks = Task.list @user.id, @user.types
    end
  end

  def show
    @task = Task.find(params[:id])
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

  end
end
