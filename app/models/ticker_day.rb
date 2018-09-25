class TickerDay < ApplicationRecord
  
  def self.hour1
    where("time >= :from_date AND time <= :to_date", {from_date: Time.now-1.hours, to_date: Time.now}).order("time desc")
  end
  
  def self.hour24
    where("time >= :from_date AND time <= :to_date", {from_date: Time.now-24.hours, to_date: Time.now}).order("time desc")
  end

  def self.day7
    where("time >= :from_date AND time <= :to_date", {from_date: Time.now-7.days, to_date: Time.now}).order("time desc")
  end

end
