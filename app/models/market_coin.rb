class MarketCoin < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  
  belongs_to :market,class_name: "Market"

  def market_name
    market.try(:name)
  end
  
  def market_rank
    market.try(:rank)
  end
  
  def exchange_amount_cny
    money = read_attribute(:exchange_amount).to_f
    "¥"+number_to_human(money.to_d, units: {unit: "元", wan: "万", yi: "亿"})
  end
  
  def exchange_count_unit
    number_to_human(read_attribute(:exchange_count).to_d, units: {unit: "", wan: "万", yi: "亿"})
  end
  
  def price_unit
    "¥"+number_with_delimiter(read_attribute(:price).to_d)
  end
end
