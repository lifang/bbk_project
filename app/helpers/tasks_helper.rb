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
  def uploadfile zipfile, zip_dir
    #创建目录
    url = "/"
    count = 0
    path.split("/").each_with_index  do |e,i|
      if i > 0 && e.size > 0
        url = url + "/" if count > 0
        url = url + "#{e}"
        if !Dir.exist? url
          Dir.mkdir url
        end
        count = count +1
      end
    end

    #重命名zip压缩包为“年-月-日_时-分-秒”
    #zipfile.original_filename = zip_dir + "." +  zipfile.original_filename.split(".").to_a[1]
    file_url = "#{path}/#{zipfile.original_filename}"
    #上传文件
    begin
      if File.open(file_url, "wb") do |file|
        file.write(zipfile.read)
      end
        return true
      end
    rescue
      File.delete file_url
      return false
    end
  end
end
