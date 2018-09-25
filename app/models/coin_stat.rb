class CoinStat < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  #monetize :cur_price,as: :curr_price,with_model_currency: "usd"
  has_one :wiki, class_name: "CoinWiki", foreign_key: "symbol"
  self.primary_key = 'symbol'
  has_many :concept_coins, foreign_key: "symbol"
  has_many :ticker_days, foreign_key: "symbol"
  
  has_many :market_coins, class_name: "MarketCoin", foreign_key: "symbol"
  has_many :markets, through: "market_coins", foreign_key: "symbol"
  
  delegate :summary,:name_en, to: :wiki, allow_nil: true

  def ico_price_cny
    wiki.try(:ico_price_cny)
  end
  
  def curr_price_cny
    money = Money.us_dollar(read_attribute(:curr_price).to_f*100).exchange_to("cny")
    money.format
  end
  
  def pub_price_cny
    money = Money.us_dollar(read_attribute(:pub_price).to_f*100).exchange_to("cny")
    money.format
  end
  
  def curr_trade_volume_cny
    money = Money.us_dollar(read_attribute(:curr_trade_volume).to_f*100).exchange_to("cny")
    money.format
  end
  
  def curr_market_value_cny
    if read_attribute(:curr_market_value)
      money = Money.us_dollar(read_attribute(:curr_market_value).to_f*100).exchange_to("cny")
      money.symbol+number_to_human(money.to_d, units: {unit: "元", wan: "万", yi: "亿"})
    end
  end
  
  
  def trade24_amount_cny
    if read_attribute(:trade24_amount)
      money = Money.us_dollar(read_attribute(:trade24_amount).to_f*100).exchange_to("cny")
      money.symbol+number_to_human(money.to_d, units: {unit: "元", wan: "万", yi: "亿"})
    end
  end
  
  def current_trade_per
    if curr_trade_count && curr_trade_volume
      (curr_trade_count/curr_trade_volume.to_f*100).round(2)
    end
  end
  
  def curr_pub_per
    Utils.percent_of(coin.high_price, coin.pub_price)
  end
  
  #较众筹上涨倍数
  def curr_ico_times
    if self.ico_price_cny && self.ico_price_cny!=0
      money = Money.us_dollar(read_attribute(:curr_price).to_f*100).exchange_to("cny")
      (Utils.percent_of(self.ico_price_cny, money.to_f)/100).round(2)
    end
  end
  
  def symbol_with_type
    self.symbol+self.symbol_type
  end
  
  def full_name
    self.symbol+ (self.symbol_zh ? "-#{self.symbol_zh}" : "")
  end
  
  def hour1_up
    start_day=ticker_days.hour1.last
    end_day=ticker_days.hour1.first
    if start_day&& end_day&& start_day.price!=0 && end_day.price!=0
      Utils.percent_of(start_day.price, end_day.price).round(2)
    else
      0
    end
  end
  
  def hour24_up
    start_day=ticker_days.hour24.last
    end_day=ticker_days.hour24.first
    if start_day&& end_day && start_day.price!=0 && end_day.price!=0
      Utils.percent_of(start_day.price.to_f, end_day.price.to_f).round(2)
    else
      0
    end
  end
  
  def day7_up
    start_day=ticker_days.day7.last
    end_day=ticker_days.day7.first
    if start_day&& end_day&& start_day.price!=0 && end_day.price!=0
      Utils.percent_of(start_day.price, end_day.price).round(2)
    else
      0
    end
  end

end
