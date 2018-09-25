class Hash
  def deep_clone
    self.map { |k, v| {k => ((!(v.target!.is_a?(String) rescue nil) && v.respond_to?(:deep_clone)) ? v.deep_clone : v)} }.inject(&:merge)
  end
end

class Array
  def deep_clone
    self.map { |v| v.respond_to?(:deep_clone) ? v.deep_clone : v }
  end
end

class String
  def format_price
  
  end
end
class Numeric
  def percent_of(n)
    (self.to_f / n.to_f * 100.0).round(1)
  end

  def percent_of_display(n)
    percent_of(n).to_s+"%"
  end

  def formatted_duration
    hours   = (self / (60 * 60)).to_i
    minutes = ((self / 60) % 60).to_i
    seconds = (self % 60).to_i
    arr     =[]
    if hours>0
      arr<< "#{ hours}小时"
    end
    if minutes>0
      arr<< "#{ minutes}分钟"
    end
    if seconds>0
      arr<< "#{ seconds }秒"
    end
    arr.join("")
  end


  def escape_hash(hash)
    (hash||{}).inject({}) do |h, (k, v)|
      if v.kind_of? String
        h[k] = URI.escape(v)
      else
        h[k] = escape_hash(v)
      end
      h
    end
  end
end

