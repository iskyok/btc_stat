class CoinWiki < ApplicationRecord
  # include ActionView::Helpers::NumberHelper
  #monetize :cur_price,as: :curr_price,with_model_currency: "usd"
  
  def curr_price_cny
    money = Money.us_dollar(read_attribute(:curr_price).to_f*100).exchange_to("cny")
    money.format
  end
  
  def pub_price_cny
    money = Money.us_dollar(read_attribute(:pub_price).to_f*100).exchange_to("cny")
    money.format
  end
  
  def curr_market_value_usd
    money = Money.us_dollar(read_attribute(:curr_market_value).to_f*100).exchange_to("cny")
    money.symbol+number_to_human(money.to_d,units: {unit: "元",wan: "万", yi: "亿"})
  end
  
  def symbol_with_type
    self.symbol+self.symbol_type
  end
end
