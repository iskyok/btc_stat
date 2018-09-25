class Company < ApplicationRecord
  has_many :invests,class_name:  "CompanyInvest"
  has_many :coin_invests,->{where(is_symbol: true)},class_name:  "CompanyInvest"
  # ,foreign_key: "company_id"
  
  def all_coins
    # where(:coins=>)
  end
  
  def full_name
    if self.name_zh==self.name
     return  self.name.to_s
    end
    self.name.to_s+ (self.name_zh ? "-#{self.name_zh}" : "")
  end
  
  def country_name
     country=Country.find_by(code: self.country_code)
     country.try(:name)
  end

  def self.find_star_range(level)
    case level
    when "high"
      where("level >=4 ")
    when "normal"
      where("level>2 and level< 4")
    when "low"
      where("level<3")
    end
  end

end
