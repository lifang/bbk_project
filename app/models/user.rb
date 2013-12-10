#encoding: utf-8
class User < ActiveRecord::Base
  STATUS ={:NORMAL =>0,:DISABLED =>1}
  VALID_STATUS = [STATUS[:DISABLED]]
  STATUS_NAME ={0=>"正常",1=>'禁用'}
  TYPES ={:ADMIN =>0,:CHECKER=>1,:PPT=>2,:FLASH=>3}
  TYPES_NAME ={0=>"管理员",1=>"质检员",2=>"PPT制作",3=>"动画制作"}

  def self.list_user status
    task_tags = TaskTag.where(status)
    @task_tags_arr = []
    task_tags.each do |task_tag|
      task_tag_id = task_tag.id
      complet_count = Task.find_by_sql("select count(*) count from tasks where tasks.`status` in (#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]}) and tasks.task_tag_id=#{task_tag_id}")
      unfinish_count = Task.find_by_sql("select count(*) count from tasks where tasks.`status` not in (#{Task::STATUS[:WAIT_FINAL_CHECK]},#{Task::STATUS[:FINAL_CHECK_COMPLETE]}) and tasks.task_tag_id=#{task_tag_id}")
      task_tags_list = task_tag.attributes
      flash_count = Task.find_by_sql("select count(*) count from tasks where task_tag_id = #{task_tag.id} and is_upload_source = 1")
      task_tags_list[:id] = task_tag.id
      task_tags_list[:name] = task_tag.name
      task_tags_list[:created_at] = task_tag.created_at.strftime("%F-%H")
      task_tags_list[:complet_count] = complet_count[0].count
      task_tags_list[:unfinish_count] = unfinish_count[0].count
      task_tags_list[:status] = task_tag.status
      task_tags_list[:flash_count] = flash_count[0].count
      @task_tags_arr << task_tags_list
    end
    @task_tags_arr
  end
end
