class MystocksController < ApplicationController
require 'csv'
require 'json'
def index
  @mystocks = Mystock.all
end

def new
  @mystock = Mystock.new
end

def search
  #@stockDatas = Mystock.all
  #模糊查询
  @stockDatas = Mystock.where("code LIKE ?", "%#{params[:stock_code]}%")
  render :json=> @stockDatas
end

def prediction
  @stock_code = params[:code]
end

def price
  #`python app/controllers/temp/autodelete.py`
  #history获取历史价格
  #stock_code=600292
  stock_code = params[:code]
  stock_code = stock_code.to_s
  stock_code = stock_code.rjust(6,'0')
  code = File.new("app/controllers/temp/code.txt","w")
  code.puts stock_code
  code.close
  #start_t=180.days.ago.strftime('%Y-%m-%d')
  #end_t=Time.now.strftime('%Y-%m-%d')
  data_file = "app/controllers/temp/data/history_" + stock_code + ".json"
  if File.exists?(data_file) then
    #@history_price = File.read(data_file)
  else
    `python app/controllers/temp/history.py`
    `python app/controllers/temp/csv2json.py`
     #json = File.read("app/controllers/temp/history.json")
  end
  @history_price = File.read(data_file)
  render :json=> @history_price
  
  #future获取预测价格
end

def create
  @mystock = Mystock.new(mystock_params)
  @mystock.save
  redirect_to '/users/1'
end

def destroy
 Mystock.find(params[:id]).destroy
 redirect_to '/mystocks'
end

private
  def mystock_params
    params.require(:mystock).permit(:name,:code)
  end
end
