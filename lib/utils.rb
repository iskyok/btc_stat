module Utils
  def self.fetch_get(url, params={}, opts={})
    default_opts={total_times: 2, info: url, file_cache: false,read_from_cache: false, override_cache: true, file_key: Digest::MD5.hexdigest(url)}
    logger=opts[:logger]
    opts=default_opts.merge(opts)
    retry_times=opts[:total_times] #请求重试次数
    
    cache_path=Rails.root.to_s+"/tmp/cache/#{opts[:file_key]}.html"
    if opts[:file_cache] && opts[:read_from_cache] && File.exist?(cache_path)
      response_result= File.read(cache_path)
    else
      begin
        re_params={
          method: :get,
          url: url,
          :headers => {
            "accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
            "accept_encoding" => "gzip, deflate, sdch",
            "accept_language" => "zh-CN,zh;q=0.8",
            "connection" => "keep-alive",
            "content_type" => "application/x-www-form-urlencoded; charset=UTF-8",
            # "host" => "m.feixiaohao.com",
            "Upgrade-Insecure-Requests"=>"1",
            # "referer" => "https://m.feixiaohao.com",
            "user_agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"
          }
        }
        # response=Faraday.get do |req|
        #   req.url url
        #   req.options.timeout = 5 # open/read timeout in seconds
        #   req.options.open_timeout = 2 # connection open timeout in seconds
        #   # req.params.merge!(params)
        # end
        # puts "====#{url}"
        response = RestClient::Request.execute(re_params)
      # rescue Faraday::ConnectionFailed, Faraday::TimeoutError
      rescue RestClient::RequestFailed, RestClient::Redirect,RestClient::RequestTimeout
        # Faraday::Error::OpenTimeoutError,Faraday::Error::ReadTimeoutError,Faraday::Error::TimeoutError
        retry_times-=1
        if logger
          logger.error "请求失败：#{opts[:info]},重试第#{opts[:total_times]-retry_times}次"
        end
        sleep 0.5
        if retry_times>0
          retry
        else
          raise "#{opts[:total_times]}次请求失败，放弃请求"
        end
      end
      if opts[:file_cache] && response
        File.open(cache_path, "wb") do |f|
          f.puts response.body
        end
      end
      response_result=response && response.body
    end
    return response_result
  end
  
  
  def self.blank_line_trim(value)
    value=value.strip
    (value.blank? || value.strip == "－") ? nil : value
  end
  
  def self.format_yes_no(value)
    if value=="是"
      return true
    elsif value=="否"
      return false
    else
      return nil
    end
  end
  
  def self.format_exception(e)
    %[#{e.class.to_s} (#{e.message}):\n\n #{e.backtrace.join("\n")}\n\n]
  end
  
  def self.convert_zh_price(value)
    value.delete("¥|,|万|?").to_f
  end
  
  def self.format_wan_price(s)
    price=self.convert_zh_price(s)
    if s.match(/万/)
      return price.to_f*10000
    else
      return price.to_f
    end
  end
  
  def self.cal_exc_time(info, &block)
    s_time=Time.now
    puts "======开始：#{info}"
    yield if block_given?
    end_time=Time.now
    used_time=(end_time-s_time).formatted_duration
    puts "=======结束：#{info},花费时间===#{used_time}"
  end
  
  
  def self.get_price_range(ranges, column)
    result=[]
    ranges.each_with_index do |price, index|
      item={}
      price_name= ActiveSupport::NumberHelper.number_to_human(price.to_d, units: {unit: "元", wan: "万", yi: "亿"})
      if index==0
        item["name"]=">#{price_name}"
        item["sql"]="#{column} > #{price}"
        item["value"]=[price, 0]
      elsif index==ranges.size-1
        item["name"]=["<#{price_name}"]
        item["sql"] ="#{column} < #{price}"
        item["value"]=[0, price]
      else
        last_price=ranges[index-1]
        last_price_name= ActiveSupport::NumberHelper.number_to_human(last_price, units: {unit: "元", wan: "万", yi: "亿"})
        price_name="#{price_name}-#{last_price_name}"
        item["name"]=price_name
        item["value"]=[price, last_price]
        item["sql"]="#{column} BETWEEN #{price} and #{last_price}"
      end
      result.push(item)
    end
    result
  end
  
  def self.percent_of(high_price, low_price)
    low_per=(low_price.to_f/high_price.to_f)
    low_price>high_price ? low_per*100 : -((1-low_per)*100)
  end
end