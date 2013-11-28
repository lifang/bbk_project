#encoding: utf-8
class AbandonTask < ActiveRecord::Base
  belongs_to :task
  TYPES = {:PPT => 0, :FLASH => 1}
  TYPES_NAME = {0 => "PPT制作", 1 => "动画制作"}
end
