class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true


  def self.find_by_price_range(column_name,range)
    puts "=====#{column_name}"
    if range[1].to_i==0
      where("#{column_name} > #{range[0]}")
    elsif range[0].to_i==0
      where("#{column_name} < #{range[1]}")
    else
      where("#{column_name} BETWEEN #{range[0]} and #{range[1]}")
    end
  end
end
