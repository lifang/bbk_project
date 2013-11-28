#encoding: utf-8
class User < ActiveRecord::Base
  STATUS ={:NORMAL =>0,:DISABLED =>1}
  VALID_STATUS = [STATUS[:DISABLED]]
  STATUS_NAME ={0=>"正常",1=>'禁用'}
  TYPES ={:ADMIN =>0,:CHECKER=>1,:PPT=>2,:FLASH=>3}
  TYPES_NAME={0=>"管理员",1=>"质检员",2=>"PPT制作",3=>"动画制作"}
end
