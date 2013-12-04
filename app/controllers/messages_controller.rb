#encoding: utf-8
class MessagesController < ApplicationController
  #发送消息
  def send
    p params[:task_id]
  end
end
