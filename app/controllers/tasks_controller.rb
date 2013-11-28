#encoding: utf-8
class TasksController < ApplicationController
  layout 'tasks'
  def index
    @title = "任务中心"
    user_id = session[:user_id] = 4
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

  def get_tasks
    notice = ""
    user_id = params[:user_id]
    @user = User.find user_id
    tasks = nil
    @info = {:notice => notice, :tasks => tasks}
  end
end
