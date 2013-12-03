#encoding: utf-8
class Calculation < ActiveRecord::Base
  IS_PAY = {:PAIED => true,:NO_PAY => false}
  IS_PAY_NAME = {true => '已付款', false => "未付款"}
end
