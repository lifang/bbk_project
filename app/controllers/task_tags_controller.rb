#encoding: utf-8
class TaskTagsController < ApplicationController
  layout "tasks"
  def show
    @task_tag = TaskTag.find params[:id]
    @title = "任务批次-#{@task_tag.name}"
    @user = User.find session[:user_id]
  end
end
