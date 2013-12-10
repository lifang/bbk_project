#encoding: utf-8
class TaskTag < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy
  has_many :accessories, :dependent => :destroy
  has_many :abandon_tasks, :dependent => :destroy
  STATUS = {:NEW => 0, :DEALING => 1, :COMPLETE => 2}
  STATUS_NAME = {0 => "新建", 1 => "进行中", 2 => "终检完成"}
end
