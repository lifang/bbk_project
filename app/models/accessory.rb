#encoding: utf-8
class Accessory < ActiveRecord::Base
  has_many :messages, :dependent => :destroy
  belongs_to :task, :dependent => :destroy
  TYPES = {:PPT =>0, :FLASH => 1}
  TYPES_NAME = {0 => "PPT", 1 => "FLASH"}
  STATUS = {:NO=>0,:YES=>1}
  STATUS_NAME = {0 => '未上传',1 => '已上传'}
end
