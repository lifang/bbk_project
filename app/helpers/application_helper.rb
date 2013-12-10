#encoding: utf-8
module ApplicationHelper
  def correct_users
    if session[:user_id].nil?
      redirect_to  "/"
    end
  end
end
