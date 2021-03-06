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
  def update_task_status task_id, task_status, user_types
    task = Task.find_by_id task_id
    case task.status
      when Task::STATUS[:WAIT_UPLOAD_PPT]
        if user_types == User::TYPES[:PPT]
          tasks = User.find_by_sql("select u.id, t.numbers from (select id from bbk_project.users where status != 1 and types = 1) u left join (select checker, count(*) as numbers from tasks where status not in (1,8,9) group by checker) t on u.id = t.checker")
          count_checker_tasks = []
          tasks.each do |task|
            task_numbers = task.numbers
            task_numbers = 0 if task_numbers.nil?  
            count_checker_tasks << [task_numbers, task.id]        
          end
          count_checker_tasks = count_checker_tasks.sort
          checker = User.find_by_id(count_checker_tasks[0][1])
          task.update_attributes(:status => Task::STATUS[:WAIT_FIRST_CHECK], :checker => checker.id)
        end  
      when Task::STATUS[:WAIT_PUB_FLASH]
        if user_types == User::TYPES[:PPT]
          task.update_attributes(:status => Task::STATUS[:WAIT_ASSIGN_FLASH])
        end  
      when Task::STATUS[:WAIT_UPLOAD_FLASH]
        if user_types == User::TYPES[:FLASH]
          task.update_attributes(:status => Task::STATUS[:WAIT_PPT_DEAL])
        end  
      when Task::STATUS[:WAIT_PPT_DEAL]
        if user_types == User::TYPES[:PPT]
          task.update_attributes(:status => Task::STATUS[:WAIT_SECOND_CHECK])
        end              
    end
    task
  end
end
