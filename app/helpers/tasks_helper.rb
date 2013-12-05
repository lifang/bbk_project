#encoding: utf-8
module TasksHelper
  def set_title
    if @title.nil?
       @title = "工作流管理"
    else
      @title
    end
  end

  #上传文件
  def upload uploadfile, file_url
    #创建目录
    root_url = "/"
    count = 0
    file_url.split("/").each_with_index  do |e,i|
      if i > 0 && e.size > 0
        root_url = root_url + "/" if count > 0
        root_url = root_url + "#{e}"
        if !Dir.exist? root_url
          Dir.mkdir root_url
        end
        count = count +1
      end
    end

    #重命名zip压缩包为“年-月-日_时-分-秒”
    #zipfile.original_filename = zip_dir + "." +  zipfile.original_filename.split(".").to_a[1]
    file_path = "#{file_url}/#{uploadfile.original_filename}"
    #上传文件
    begin
      if File.open(file_path, "wb") do |file|
        file.write(uploadfile.read)
      end
        return true
      end
    rescue
      File.delete file_path
      return false
    end
  end

  #工作流程中上传文件或更新任务状态
  def update_task_status task_id, task_status
    task = Task.find task_id
    case task.status
      when Task::STATUS[:WAIT_UPLOAD_PPT]
        checker = User.find_by_status_and_types(User::STATUS[:NORMAL], User::TYPES[:CHECKER])
        task.update_attributes(:status => Task::STATUS[:WAIT_FIRST_CHECK], :checker => checker.id)
      when Task::STATUS[:WAIT_PUB_FLASH]
        task.update_attributes(:status => Task::STATUS[:WAIT_ASSIGN_FLASH])
      when Task::STATUS[:WAIT_UPLOAD_FLASH]
        task.update_attributes(:status => Task::STATUS[:WAIT_PPT_DEAL])
      when Task::STATUS[:WAIT_PPT_DEAL]
        task.update_attributes(:status => Task::STATUS[:WAIT_SECOND_CHECK])
    end
    task
  end
end
