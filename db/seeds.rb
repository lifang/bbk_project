#encoding: utf-8
  #创建用户
  name = ["zhu","zhao","zhang","li"]
  (0..3).each do |e|
    User.create(:name => name[e], :password => "123456", :types => e, :status => 0, :phone=>"123456#{e}",
              :address => "星海街#{e}号10#{e}室")
  end

  #创建任务
  (1..9).each do |e|
    task_tag = TaskTag.create(:name => "课件任务#{e}")
    (1..9).each do |x|
      task = Task.create(:name => "PPT课件#{x}", :status => 0, :task_tag_id => task_tag.id)
      task.update_attributes(:origin_ppt_url => "/accessories/task_tag_#{task_tag.id}
          /task_#{task.id}/ppt/ppt_v1.0.ppt", :origin_flash_url => "/accessories/task_tag_#{task_tag.id}
          /task_#{task.id}/swf/swf_v1.0.zip")
    end
  end
