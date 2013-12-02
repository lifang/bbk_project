#encoding: utf-8
require 'fileutils'
require 'archive/zip'
class UsersController < ApplicationController
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
  def destroy
    session[:user_id] = nil
    redirect_to "/"
  end
  #管理员页面
  def management
    status = params[:status].nil? || params[:status].strip.blank? ? "1=1" : ["url = ?", params[:status].strip]
    task_tags = TaskTag.task_tag_stats(status)
    @task_tags_arr = []
    task_tags.each do |task_tag|
      task_tag_id = task_tag.id
      complet_count = Task.find_by_sql("select count(*) count from tasks where tasks.`status` in (#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]}) and tasks.task_tag_id=#{task_tag_id}")
      unfinish_count = Task.find_by_sql("select count(*) count from tasks where tasks.`status` not in (#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]}) and tasks.task_tag_id=#{task_tag_id}")
      task_tags_list = task_tag.attributes
      task_tags_list[:id] = task_tag.id
      task_tags_list[:name] = task_tag.name
      task_tags_list[:created_at] = task_tag.created_at
      task_tags_list[:complet_count] = complet_count[0].count
      task_tags_list[:unfinish_count] = unfinish_count[0].count
      task_tags_list[:status] = task_tag.status
      @task_tags_arr << task_tags_list
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
  #下载任务
  def download
    params[:task_tag_id]
    tasks = Task.find_by_sql("select * from tasks where tasks.`status` in (#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]}) and tasks.task_tag_id = #{params[:task_tag_id]}")
    zip_url = "#{Rails.root}/public/accessories/"
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

end
