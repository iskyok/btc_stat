CompanyInvest.all.each do |com|
  coin=CoinStat.find_by(fxh_symbol: com.name.downcase)
  if coin
    com.update_attributes({symbol: coin.symbol})
  end
end