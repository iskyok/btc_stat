class CoinFeed < ApplicationRecord
  
  acts_as_taggable # Alias for acts_as_taggable_on :tags
  
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
end
