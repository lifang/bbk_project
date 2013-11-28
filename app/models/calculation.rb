#encoding: utf-8
class Calculation < ActiveRecord::Base
  IS_PAY = {:PAIED => 0,:NO_PAY => 1}
  IS_PAY_NAME = {0 => '已付款', 1 => "未付款"}
end
