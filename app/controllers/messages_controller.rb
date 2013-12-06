#encoding: utf-8
class MessagesController < ApplicationController
  #发送消息
  def send_msg
    @user = User.find_by_id params[:user_id]
    @task = Task.find_by_id params[:task_id]
    @from = params[:from]
    @reciver = User.find_by_id params[:reciver_id]
    @accessory = Accessory.find_by_id params[:accessory_id]
    content = params[:content].to_s
    if content.gsub(' ','').size != 0
      @accessory.messages.create(:sender_id => @user.id, :reciver_id => @reciver.id,  :content => content)
    end
    @messages = @accessory.messages
    case @user.types
      when User::TYPES[:PPT]
        @left_reciver = User.find_by_id @task.checker
        @right_reciver = User.find_by_id @task.flash_doer
      when User::TYPES[:FLASH]
        @right_reciver = User.find_by_id @task.ppt_doer
      when User::TYPES[:CHECKER]
        @left_reciver = User.find_by_id @task.ppt_doer
    end
  end

  #刷新消息
  def reload_msg
    @user = User.find_by_id params[:user_id]
    @task = Task.find_by_id params[:task_id]
    @from = params[:from]
    @reciver = User.find_by_id params[:reciver_id]
    @accessory = Accessory.find_by_id params[:accessory_id]
    @messages = @accessory.messages
  end
end
