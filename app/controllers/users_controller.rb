#encoding: utf-8
require 'fileutils'
require 'archive/zip'
require 'iconv'
class UsersController < ApplicationController
  before_filter :correct_users, :only =>[:management]
  #登录页面
  def index
    user = User.find_by_id(session[:user_id].to_i)
    if user.nil?
      render :index
    else
      if user.types == User::TYPES[:ADMIN]
        redirect_to  :controller => :users, :action => :management
      else
        redirect_to  :controller => :tasks, :action => :index
      end
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
  def logout
    session[:user_id] = nil
    render :index
  end
  #管理员页面
  def management
    @user = User.find_by_id session[:user_id]
    status = params[:status].nil? || params[:status].strip.blank? ? "1=1" : ["url = ?", params[:status].strip]
    if !@user.nil? && @user.types == User::TYPES[:ADMIN]
      @task_tags_arr = User.list_user status
    else
      redirect_to "/"
    end
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
      #解压
      Archive::Zip.extract("#{zip_url}.zip","#{Rails.root}/public/accessories")
      `convmv -f gbk -t utf-8 -r --notest  #{Rails.root}/public/accessories`
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
          tasks = Task.create(:name => ppt_name,:is_upload_source => 0,:origin_ppt_url => origin_ppt_url,:status => 0,:task_tag_id => task_tags.id,:is_calculate => 1)
          tasks_id = tasks.id
          # 任务包名
          task_url = "#{File.expand_path(Rails.root)}/public/accessories/#{newfilename}" + "/task_" + tasks_id.to_s + "/origin"
          FileUtils.mkdir_p "#{File.expand_path(task_url)}" if !(File.exist?("#{File.expand_path(task_url)}"))
          FileUtils.mv file_old_url,task_url,:force => true
          ppt_sql_save = "/accessories/#{newfilename}" + "/task_" + tasks_id.to_s + "/origin/" + file
          tasks.update_attributes(:origin_ppt_url => ppt_sql_save)
        end
      end
      FileUtils.rm_rf "#{zip_url}"
    rescue
      @successornot = '上传失败'
      File.delete "#{zip_url}.zip"
      FileUtils.rm_rf "#{zip_url}"
    end
    status = params[:status].nil? || params[:status].strip.blank? ? "1=1" : ["url = ?", params[:status].strip]
    @task_tags_arr = User.list_user status
  end
  #下载任务
  def download
    zip_url = "#{Rails.root}/public/accessories/"
    if   File.exist?("#{zip_url}1234.zip")
      File.delete "#{zip_url}1234.zip"
    end
    params[:task_tag_id]
    tasks = Task.find_by_sql("select * from tasks where tasks.`status` in (#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]}) and tasks.task_tag_id = #{params[:task_tag_id]}")
    tasks.each do |task|
      task_id = task.id
      accessory = Accessory.find_by_sql("SELECT  * from accessories where task_id = #{task_id} ORDER BY created_at DESC limit 1")
      if !accessory.blank?
        accessory_url = accessory[0].accessory_url
        file_url = "#{Rails.root}/public" + accessory_url
        Archive::Zip.archive("#{zip_url}1234.zip","#{file_url}")
      end
    end
    render :json => {:status => 1}
  end
  #下载
  def ajax_download
    file_path = "#{Rails.root}/public/accessories/1234.zip"
    if file_path
      send_file file_path, :filename => '12345.zip'
    end
  end
  #下载flash元件
  def flash_download
    zip_url = "#{Rails.root}/public/accessories/"
    if   File.exist?("#{zip_url}flash.zip")
      File.delete "#{zip_url}flash.zip"
    end
    tasks = Task.find_by_sql("SELECT * from tasks where is_upload_source = #{Task::IS_UPLOAD_SOURCE[:YES]} and task_tag_id = #{params[:task_tag_id]}")
    tasks.each do |task|
      source_url = task.source_url
      if !source_url.blank?
        file_url = "#{Rails.root}/public" + source_url
        Archive::Zip.archive("#{zip_url}flash.zip","#{file_url}")
      end
    end
    if File.exist?("#{zip_url}flash.zip")
      send_file "#{zip_url}flash.zip", :filename => 'flash.zip'
    else
      render "/users/index"
    end
  end
  #确认终检
  def confirm_final
    task_tag = TaskTag.find_by_id(params[:task_tag_id])
    TaskTag.transaction do
      @task = Task.where(:task_tag_id => params[:task_tag_id])
      @task.each do |task|
        task.update_attributes(:status => 9)
      end
      task_tag.update_attributes( :status => 2 )
    end
    render :json => {:status => 0}
    #    if !task_tag.status.eql?(TaskTag::STATUS[:COMPLETE])
    #      render :json => {:status => 0}
    #    else
    #      render :json => {:status => 1}
    #    end
  end
  #用户管理
  def user_management
    @users = User.where(:status => 0)
  end
  #添加用户
  def add_user
    name = params[:user][:name]
    @user_exist = User.find_by_name(name)
    password = params[:user][:password]
    types = params[:types].to_i
    phone = params[:user][:phone]
    address = params[:user][:address]
    if @user_exist.blank?
      @user = User.create(:name => name,:password => password,:types => types,:phone => phone,:address => address,:status => 0)
    end
  end
  #修改用户
  def edit
    @user = User.find(params[:user_id])
  end
  #更新用户
  def modify_user
    @user_exist_id =  User.find(params[:user][:id])
    password = params[:user][:password]
    types = params[:types].to_i
    phone = params[:user][:phone]
    address = params[:user][:address]
    @user = @user_exist.update_attributes(:password => password,:types => types,:phone => phone,:address => address)
  end
  # 禁用用户
  def disable_user
    user_id = params[:user_id]
    user = User.find(user_id)
    @user = user.update_attributes(:status => User::STATUS[:DISABLED])
    @users = User.where(:status => 0)
  end
end
