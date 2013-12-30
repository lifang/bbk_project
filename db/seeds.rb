#encoding: utf-8
  #创建用户
  name = "admin"
  User.create(:name => name, :password => "admin123456", :types => 0, :status => 0)