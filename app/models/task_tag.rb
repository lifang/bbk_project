#encoding: utf-8
class TaskTag < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy
  has_many :accessories, :dependent => :destroy
  has_many :abandon_tasks, :dependent => :destroy
  STATUS = {:NEW => 0, :DEALING => 1, :COMPLETE => 2}
  STATUS_NAME = {0 => "新建", 1 => "进行中", 2 => "完成"}

  def self.task_tag_stats status
    by_sql = "SELECT tt.name  name ,tt.created_at timess,tt.status sta, count1.scc,count2.suu from task_tags tt,
(select count(*) scc,t1.task_tag_id id from tasks t1,task_tags tt1 where t1.task_tag_id = tt1.id and t1.status in (8,9) GROUP BY t1.task_tag_id) count1,
(select count(*) suu,t2.task_tag_id id from tasks t2,task_tags tt2 where t2.task_tag_id = tt2.id and t2.status not in (8,9) GROUP BY t2.task_tag_id) count2
where tt.id = count1.id and count2.id = tt.id"
    if status.nil? || status == ""
    else
      task_tags_status = "tt.status = '#{status}'"
      by_sql << task_tags_status
    end
    TaskTag.find_by_sql(by_sql)
  end
end
