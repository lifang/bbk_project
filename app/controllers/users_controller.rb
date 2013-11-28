#encoding: utf-8
require 'fileutils'
require 'archive/zip'
class UsersController < ApplicationController
  #登录页面
  def index
    session[:user_id] =nil
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
      if user.types == User::TYPES[:ADMIN]
        redirect_to  "/users/management"
      elsif user.types == User::TYPES[:CHECKER] || user.types == User::TYPES[:PPT] || user.types == User::TYPES[:FLASH]
        redirect_to :controller => :tasks, :action => :index
      else
        session[:user_id] = nil
        flash.now[:notice] = "错误的用户类型，请输入正确的用户"
        render :index
      end
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
  #上传ppt
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
    begin
      Archive::Zip.extract("#{zip_url}.zip","#{Rails.root}/public/accessories")
      File.delete "#{zip_url}.zip"
      task_tags = TaskTag.create(:name => filename_body, :status => 0)
      newfilename = "task_tag_" << task_tags.id.to_s
      FileUtils.mkdir_p "#{File.expand_path(Rails.root)}/public/accessories/#{newfilename}" if !(File.exist?("#{File.expand_path(Rails.root)}/public/accessories/#{newfilename}"))
      Dir.foreach(zip_url) do |file|
        suffix = file.split(".")[1].to_s
        ppt_name = file.split(".")[0].to_s
        if suffix.eql?("ppt")
          file_old_url = zip_url + '/' + file
          origin_ppt_url = "/" + newfilename +"/" + file
          FileUtils.mv file_old_url,"#{File.expand_path(Rails.root)}/public/accessories/#{newfilename}",:force => true
          Task.create(:name => ppt_name,:types => 0,:origin_ppt_url => origin_ppt_url,:status => 0,:task_tag_id => task_tags.id)
        end
      end
      FileUtils.rm_rf "#{zip_url}"
    rescue
      @successornot = '上传失败'
      File.delete "#{zip_url}.zip"
      FileUtils.rm_rf "#{zip_url}"
    end
  end
end
