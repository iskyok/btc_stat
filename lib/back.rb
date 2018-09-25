BASE_URL="https://mapi.feixiaohao.com".freeze
@@conn = Faraday.new(:url => BASE_URL) do |faraday|
  faraday.request :url_encoded # form-encode POST params
  # faraday.response :logger # log requests to STDOUT
  faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
end


class << self
  def handle_coin_line(latest_day, coin)
    # start_time=Time.parse("2013-04-29 02:47:21").to_i*1000; #初始化数据时间
    if latest_day
      start_time=latest_day.time.to_i*1000 #上次数据时间
    else
      start_time=Time.parse("2013-04-29 02:47:21").to_i*1000; #初始化数据时间
    end
    end_time=Time.now.to_i*1000
    puts "====请求：#{coin.symbol} ==== #{Time.at(start_time/1000)}-#{Time.at(end_time/1000)}"
    puts "====请求url：https://mapi.feixiaohao.com/coinhisdata/#{coin.symbol}/#{start_time}/#{end_time}/"
    # return if latest_day.time.to_date==Time.now.to_date
    url= "/coinhisdata/#{coin.fxh_symbol}/#{start_time}/#{end_time}/?wscckey=04e99821ae521cc8_1517946780"
    # response = Faraday.get url
    total_times=3
    retry_times=total_times #请求重试次数
    begin
      response=@@conn.get do |req|
        req.url url
        req.options.timeout = 5 # open/read timeout in seconds
        req.options.open_timeout = 2 # connection open timeout in seconds
      end
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError
      # Faraday::Error::OpenTimeoutError,Faraday::Error::ReadTimeoutError,Faraday::Error::TimeoutError
      retry_times-=1
      puts "请求失败：#{coin.symbol},重试第#{total_times-retry_times}次"
      sleep 0.5
      if retry_times>0
        retry
      else
        raise "#{total_times}次请求失败，放弃请求"
      end
    end
    if response && response.status==200
      puts "=====11#{response.body}"
      self.parse(response.body, coin, url)
      $fxh_logger.info(coin.symbol+"：成功")
    else
      $fxh_logger.error(coin.symbol+"：失败")
      raise "请求数据错误======"
    end
  end
end