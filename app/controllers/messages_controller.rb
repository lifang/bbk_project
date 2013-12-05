#encoding: utf-8
class MessagesController < ApplicationController
  #发送消息
  def send_msg
    @user = User.find_by_id params[:user_id]
    @task = Task.find_by_id params[:task_id]
    @accessory = Accessory.find_by_id params[:accessory_id]
    content = params[:content].to_s
    if content.gsub(' ','').size != 0
      @accessory.messages.create(:sender_id => @user.id, :content => content)
    end
    @messages = @accessory.messages
  end

  #刷新消息
  def reload_msg
    user = User.find_by_id params[:user_id]
    task = Task.find_by_id params[:task_id]

  end

end
