class Market < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  
  def self.find_star_range(level)
    case level
    when "high"
      where("star = 5 ")
    when "normal"
      where("star>2 and star< 5")
    when "low"
      where("star<3")
    end
  end

  def amount24_cny
    money = read_attribute(:amount24).to_f*10000
    "¥"+number_to_human(money.to_d, units: {unit: "元", wan: "万", yi: "亿"})
  end
  
end
