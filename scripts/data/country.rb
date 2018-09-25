def load_market_country
  Market.all.group_by(&:country_name).each do |country_name, markets|
    if country_name.blank?
      next
    end
    country=Country.where(name: country_name).first_or_initialize
    code=Market.find_by(country_name: country_name).country_code
    country.code=code
    country.market_count=markets.size
    country.save!
  end
end

load_market_country