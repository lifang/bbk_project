#encoding: utf-8
class Accessory < ActiveRecord::Base
  has_many :messages,:dependent => :destroy
  STATUS = {:YES=>0,:NO=>1}
  STATUS_NAME = {0 => '已上传',1 => '未上传'}
end
