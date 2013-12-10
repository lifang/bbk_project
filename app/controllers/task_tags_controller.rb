#encoding: utf-8
class TaskTagsController < ApplicationController
  layout "tasks"
  def show
    @user = User.find_by_id session[:user_id]
    if !@user.nil? && @user.types != User::TYPES[:ADMIN]
      @task_tag = TaskTag.find params[:id]
      @title = "任务批次-#{@task_tag.name}"
    else
      redirect_to root_url
    end
  end
end
