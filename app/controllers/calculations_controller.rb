#encoding: utf-8
class CalculationsController < ApplicationController
  # 工资结算
  def wage_settlement
    admin = User.find_by_name("admin")
    #    manth = admin.created_at.strftime("%Y-%m")
    @months = Calculation.find_by_sql("SELECT `month` from calculations GROUP BY `month` DESC")
    month = @months[0].month
    #    p admin.created_at
    #    p Time.now
    #    params[:month]
    @calculation = Calculation.find_by_sql("SELECT calculations.id, users.name,users.types,calculations.time,calculations.is_pay from
calculations,users WHERE calculations.user_id = users.id and calculations.month = '#{month}'")
  end
  def settlement_list
    month = params[:month].nil? || params[:month].strip.blank? ? '1=1' : "calculations.month = '#{params[:month].to_s}'"
    types = params[:types].nil? || params[:types].strip.blank? ? '1=1' : "users.types = #{params[:types].to_i}"
    @calculation = Calculation.find_by_sql("SELECT calculations.id, users.name,users.types,calculations.time,calculations.is_pay from
calculations,users WHERE calculations.user_id = users.id and #{month} and #{types}")
  end
  #是否付款
  def whether_payment
    calculation = Calculation.find(params[:calculation_id])
    p calculation.is_pay
    if calculation.is_pay
      calculation.update_attributes(:is_pay => 0)
      p 1111111111
      render :json => {:status => 0}
    else
      p 2222222222
      calculation.update_attributes(:is_pay => 1)
      render :json => {:status => 1}
    end
  end
end
