require 'parallel'
@api_key="LP3hhXt1tdK2PoQF0jZmH7fYhcNarFdk4YUK8QQ1JW4Cp9oW2X1fzIYv2gnNJQh7"
@secret="pjkGnCqDRtwmJ9jDb1xPlokAKvYwZdpmCDH3bGvIOxpBq6YJA4foqAqvdxBvt2pT"

@client = Binance::Client::REST.new(api_key: @api_key,secret_key: @secret)

#通过周线获取统计信息
# data=@client.klines symbol: "BNBBTC",interval: '1w'
# data.map{|item|item[2]}.max

def get_coin_line(coin)
  data=@client.klines symbol: coin.symbol_with_type, interval: '1w'
  result=[]
  data.each do |min_data|
    item={}
    item[:symbol]=coin.symbol
    item[:start_time]=Time.at(min_data[0]/1000)
    item[:end_time]=Time.at(min_data[6]/1000)
    item[:open_price]= min_data[1]
    item[:close_price]= min_data[4]
    item[:high_price]= min_data[2]
    item[:low_price]= min_data[3]
    item[:trade_count]= min_data[8]
    item[:volume]= min_data[5]
    result<<item
  end
  result
end

#
# def get_coin_line(coin)
#   data=@client.klines symbol: coin.symbol_with_type, interval: '1w'
#   max_prices=data.map { |item| item[2] }
#   min_data=data[0]
#   coin.pub_at=Time.at(min_data[0]/1000)
#   coin.pub_price= min_data[3]
#   coin.max_price=max_prices.max
#   coin.max_at=Time.at(data[max_prices.index(max_prices.max)][0]/1000)
#   coin.save!
# end

def update_all_coins_week
  Parallel.each(CoinStat.all, in_threads: 8) do |coin|
    ActiveRecord::Base.connection_pool.with_connection do
      result=get_coin_line(coin)
      TickerWeek.create(result)
    end
  end
end

#获取全部货币(all_prices)
def all_coins
  puts data=@client.all_prices
  symbol_types=["BTC", "ETH", "BNB", "USDT"]
  # data.each do |item|
  #   next if item['symbol']=="123456"
  #   symbol_item=item["symbol"].match /(.*)(BTC|ETH|BNB|USDT)/
  #   puts "====#{symbol_item}"
  #   symbol=symbol_item[1]
  #   symbol_type=symbol_item[-1]
  #   if symbol_type=="BTC"
  #     coin=CoinStat.find_or_create_by(symbol: symbol, symbol_type: symbol_type)
  #     coin.currency = symbol_type
  #     coin.save!
  #   end
  # end
end


def get_coin_stat(coin)
  ticker_weeks=TickerWeek.where(symbol: coin.symbol)
  weeks=ticker_weeks.order(start_time: :desc)
  high_price_week=ticker_weeks.order(high_price: :desc).first
  low_price_week=ticker_weeks.order(high_price: :asc).first
  result={}
  result[:pub_at]=weeks.last.start_time
  result[:pub_price]= weeks.last.open_price
  result[:low_price]= low_price_week.low_price
  result[:low_at]= low_price_week.start_time
  result[:high_price]=high_price_week.high_price
  result[:high_at]=high_price_week.start_time
  result
end



# update_coin_stat
# puts @client.account_info
puts @client.all_book_tickers


# update_all_coins_week
# all_coins

# [
#   [
#     1499040000000, // Open time 0
# "0.01634790", // Open 1
# "0.80000000", // High 2
# "0.01575800", // Low 3
# "0.01577100", // Close 4
# "148976.11427815", // Volume 5
# 1499644799999, // Close time 6
# "2434.19055334", // Quote asset volume 7
# 308, // Number of trades 8
# "1756.87402397", // Taker buy base asset volume 9
# "28.46694368", // Taker buy quote asset volume 10
# "17928899.62484339" // Can be ignored  11
# 		  ]
# 		]
#

# {
#   "priceChange": "-94.99999800",#24h涨跌
#   "priceChangePercent": "-95.960", #24h涨跌
#   "weightedAvgPrice": "0.29628482",
#   "prevClosePrice": "0.10002000",
#   "lastPrice": "4.00000200",
#   "bidPrice": "4.00000000",买方出价
#   "askPrice": "4.00000200",卖方开价
#   "openPrice": "99.00000000",
#   "highPrice": "100.00000000",#24h最高价
#   "lowPrice": "0.10000000",#最低价
#   "volume": "8913.30000000",#成交量
#   "openTime": 1499783499040,#24小时开始时间
#   "closeTime": 1499869899040,#24小时结束时间
#   "fristId": 28385,   // First tradeId
#    "lastId": 28460,    // Last tradeId
#    "count": 76         // Trade count #交易数量
# 		}