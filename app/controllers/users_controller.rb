#encoding: utf-8
require 'fileutils'
require 'archive/zip'
class UsersController < ApplicationController
  #登录页面
  def index
    if session[:user_id]
      user = User.find_by_id(session[:user_id].to_i)
      if user.nil?
        render :index
      else
        redirect_to  :controller => :users, :action => :management
      end
    else
      render :index
    end
  end
  #登录
  def login
    user = User.find_by_name(params[:user][:name])
    if user.nil? or User::VALID_STATUS.include?(user.status)
      flash.now[:notice] = "用户名不存在"
      render :index
    elsif !user.password.eql?(params[:user][:password])
      flash.now[:notice] = "密码错误"
      render :index
    else
      session[:user_id] = user.id
      redirect_to  "/users/management"
    end
  end
  #注销登录
  def destroy
    session[:user_id] = nil
    redirect_to "/"
  end
  #管理员页面
  def management
    @task_tags = TaskTag.task_tag_stats(params[:status])
  end
  #上传照片
  def upload
    FileUtils.mkdir_p "#{File.expand_path(Rails.root)}/public/accessories" if !(File.exist?("#{File.expand_path(Rails.root)}/public/accessories"))
    file_upload = params[:file_upload]
    filename = file_upload.original_filename
    filename_body =  filename.split(".")[0]
    zip_url = "#{Rails.root}/public/accessories/#{filename_body}"
    File.open("#{zip_url}.zip","wb") do |f|
      f.write(file_upload.read)
    end
    @successornot = '上传成功'
    FileUtils.mkdir_p "#{File.expand_path(Rails.root)}/public/accessories/#{filename_body}" if !(File.exist?("#{File.expand_path(Rails.root)}/public/accessories/#{filename_body}"))
    begin
      Archive::Zip.extract("#{zip_url}.zip","#{zip_url}")
      File.delete "#{zip_url}.zip"
    rescue
      @successornot = '上传失败'
      File.delete "#{zip_url}.zip"
      FileUtils.rm_rf "#{zip_url}"
    end
  end
end
