module CoinApi
  class Feixiaohao
    class_attribute :wscckey
    class_attribute :cookies
    #价格走势数据
    #https://mapi.feixiaohao.com/coinhisdata/omni/1367174841000/1516257867000/
    $logger = Logger.new("#{Rails.root}/log/feixiaohao_error.log")
    $fxh_logger = Logger.new("#{Rails.root}/log/feixiaohao.log")
    
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
        url= "https://mapi.feixiaohao.com/coinhisdata/#{coin.fxh_symbol}/#{start_time}/#{end_time}?wscckey=04e99821ae521cc8_1517946780"
        json_result=Utils.fetch_get(url, {}, {info: coin.symbol, logger: $logger, file_cache: true})
        puts "=====11#{json_result}"
        self.parse(json_result, coin, url)
      end
      
      def parse(data, coin, url)
        begin
          data=JSON.parse(data)
          result=data["price_usd"].map { |item| {currency: "usd", symbol: coin.symbol, price: item[1], time: Time.at(item[0]/1000)} }
        rescue Exception => e
          raise "#{url} 解析数据错误======\n #{e.message}"
        end
      end
      
      def load_all_coin_line
        `echo "">#{Rails.root}/log/feixiaohao.log`
        `echo "">#{Rails.root}/log/feixiaohao_error.log`
        # total_request=1
        total_request=CoinStat.count
        total_threads=5
        s_time=Time.now
        #CoinStat.order("curr_market_value desc").limit(total_request).each do |coin|
        #  load_coin_line(CoinStat.find_by(symbol: coin.symbol))
        #end
        puts "=====开始 #{total_request}次请求，#{total_threads}个并发 "
        all_coins=CoinStat.order("curr_market_value desc").limit(total_request)
        # all_coins=CoinStat.order("id asc").limit(total_request)
        Parallel.map(all_coins, in_threads: total_threads) do |coin|
          ActiveRecord::Base.connection_pool.with_connection do
            begin
              latest_day=TickerDay.where(symbol: coin.symbol).order("time asc").last
              result=handle_coin_line(latest_day, coin)
              puts "======#{result}"
              if result.size>0
                TickerDay.import!(result)
                ticker_days=TickerDay.where(symbol: coin.symbol)
                result=self.get_coin_stat(ticker_days)
                coin.update_attributes(result)
                self.update_up_price(coin)
              end
            rescue Exception => e
              $logger.error %[#{e.class.to_s} (#{e.message}):\n\n #{e.backtrace.join("\n")}\n\n]
            end
          end
        end
        # 手写线程
        # all_coins.find_in_batches(batch_size: total_threads).with_index do |coins, index|
        #   # puts "###第#{index}批数据 开始##"
        #   threads = coins.map.each do |coin|
        #     Thread.new(coin.id) do
        #       latest_day=TickerDay.where(symbol: coin.symbol).order("time asc").last
        #       begin
        #         handle_coin_line(latest_day, coin)
        #       rescue Exception => e
        #         $logger.error %[#{e.class.to_s} (#{e.message}):\n\n #{e.backtrace.join("\n")}\n\n]
        #       end
        #     end
        #   end
        #   threads.map(&:join)
        #   # puts "###第#{index}批数据 结束##"
        # end
        
        end_time=Time.now
        used_time=(end_time-s_time).formatted_duration
        puts "=======#{total_request}次请求，#{total_threads}个并发，花费时间===#{used_time}"
        # self.update_coin_stat
        $fxh_logger.close
      end
      
      
      def get_coin_stat(ticker_days)
        days=ticker_days.order(time: :desc)
        high_price_day=ticker_days.order(price: :desc).first
        low_price_day=ticker_days.order(price: :asc).first
        result={}
        result[:curr_price]=days.first.price
        result[:pub_at]=days.last.time
        result[:pub_price]= days.last.price
        result[:low_price]= low_price_day.price
        result[:low_at]= low_price_day.time
        result[:high_price]=high_price_day.price
        result[:high_at]=high_price_day.time
        result[:price_updated_at]=days.first.time
        result
      end
      
      #统计所有货币信息
      def update_coin_stat
        total_threads=10
        s_time=Time.now
        puts "=======开始#{CoinStat.all.count}个货币更新，#{total_threads}个并发"
        Parallel.each(CoinStat.all, in_threads: total_threads) do |coin|
          ActiveRecord::Base.connection_pool.with_connection do
            ticker_days=TickerDay.where(symbol: coin.symbol)
            if ticker_days.count>0
              result=self.get_coin_stat(ticker_days)
              coin.update_attributes(result)
            end
          end
        end
        end_time=Time.now
        used_time=(end_time-s_time).formatted_duration
        puts "=======完成#{CoinStat.all.count}个货币更新，#{total_threads}个并发，花费时间===#{used_time}"
      end
      
      def update_up_price(coin)
        result={}
        if coin.high_price && coin.curr_price && coin.pub_price
          result[:max_up_per]=Utils.percent_of(coin.pub_price,coin.high_pub)
          result[:curr_up_per]=Utils.percent_of(coin.pub_price,coin.curr_price)
          coin.update_attributes(result)
        end
      end
      
      def load_all_coin_by_page(page=1)
        response = RestClient.get "#{BASE_URL}/v2/morecoin?coinType=0&sortType=0&page=#{page}"
        #tmp_path="#{Rails.root}/tmp/feixiaohao_morecoin.html"
        #html_result=File.read(tmp_path)
        html_reswult=response.body
        html=JSON.parse(html_result)["result2"]
        doc=Nokogiri::HTML(html)
        doc.css("tr").each_with_index do |row, index|
          result={}
          result[:currency]="usd" #汇率
          result[:symbol]=row.css('td')[1].text #种类
          if item=row.css("td a")[0]["href"]
            result[:fxh_symbol]=item.split(/\//)[-1] #标记
          end
          # result[:curr_price]=row.css("td a")[1]["data-usd"] #价格（美金）
          result[:curr_hour24_up]=row.css('td')[3].text.gsub(/\%/, "") #涨幅(24h)
          market_value=row.css('td')[4]["data-usd"]
          result[:curr_market_value]=market_value if market_value.match(/\d+/) #流通市值(亿)
          result[:curr_trade_count]=row.css('td')[5].text.split("万")[0].delete(",") #流通数量（万）
          result[:curr_trade_volume]=row.css('td a')[2]["data-usd"] #总发行量（万）
          stat=CoinStat.where(symbol: result[:symbol]).first_or_initialize
          stat.attributes=result
          stat.save!
        end
      end
      
      #全部货币列表：op500
      def load_all_coins
        # Parallel.map(0..15, in_threads: 5) do |page|
        #   ActiveRecord::Base.connection_pool.with_connection do
        # load_all_coin_by_page(page)
        load_all_coin_by_page(13)
        # end
        # end
      end
      
      def parse_coin_show(coin,html)
        doc=Nokogiri::HTML(html)
        result={}
        raw_price=doc.css(".price1 .sub div")
        puts "====#{coin.symbol}==rrrrr==##{result}"
        result[:curr_price]=raw_price.text.delete("≈$|,").to_f
        result[:trade24_amount]=doc.css(".mainInfo")[0].css(".leftside .sub")[0].text.delete("≈$|,").to_f
        curr_market_value=doc.css(".mainInfo")[1].css(".leftside .sub")[0].text.delete("≈$|,").to_f
        result[:curr_market_value]=curr_market_value if curr_market_value!=0
        curr_trade_count=doc.css(".mainInfo")[2].css(".leftside .val")[0].text.split(" ")[0].delete(",")
        result[:curr_trade_count]=curr_trade_count if curr_trade_count!=0
        curr_trade_volume=doc.css(".mainInfo")[2].css(".leftside .val")[1].text.split(" ")[0].delete(",")
        result[:curr_trade_volume]=curr_trade_volume if curr_trade_volume!=0
        # puts "====#{coin.symbol}==rrrrr==##{result}"
        result[:price_updated_at]=Time.now  if result[:curr_price].present?
        result
      end
      
      #获取所有币的市值、成交价格信息
      def load_all_prices
        all_coins=CoinStat.order("curr_market_value desc")
        total_request=all_coins.count
        total_threads=10
        self.wscckey=nil
        Utils.cal_exc_time("#{total_request}次请求，#{total_threads}个并发") do
          Parallel.each(all_coins, in_threads: total_threads) do |coin|
            ActiveRecord::Base.connection_pool.with_connection do
              begin
                url="https://m.feixiaohao.com/currencies/#{coin.fxh_symbol}"
                params={}
                params[:wscckey]=self.wscckey if self.wscckey
                html_result=Utils.fetch_get(url,params, {info: coin.symbol, logger: $logger, file_cache: true})
                if html_result.match(/wscckey/)
                  self.wscckey=html_result.match(/wscckey=([a-zA-Z0-9_]*)/)[1]
                  # params[:wscckey]=self.wscckey
                  puts "nnnnn--------#{params}"
                  url="https://m.feixiaohao.com/currencies/#{coin.fxh_symbol}"
                  url+="?wscckey=#{self.wscckey}" if self.wscckey
                  html_result=Utils.fetch_get(url,{}, {info: coin.symbol, logger: $logger, file_cache: true})
                end
              rescue => e
                $logger.error(e.message)
                next
              end
              begin
                # puts "ddddd======#{html_result}"
                result=parse_coin_show(coin,html_result)
                coin=CoinStat.where(symbol: coin.symbol).first_or_initialize
                coin.attributes=result
                if coin.curr_price && coin.pub_price
                  coin.curr_up_per=Utils.percent_of(coin.pub_price,coin.curr_price)
                end
                coin.save!
              rescue => e
                $logger.error("解析错误#{coin.symbol}==>#{e.message}")
                puts Utils.format_exception(e)
              end
              # puts "===####rrrr#{result}"
              sleep 0.5
            end
          end
        end
      end
      
      #获取货币百科信息
      #解析coinwiki
      def parse_wiki(html)
        doc=Nokogiri::HTML(html)
        cell_map={"name_en": "英文名", "name_zh": "中文名", "on_market_count": "上架交易所",
                  "pub_at": "发行时间", "white_paper": "白皮书", "website": "网站", "explorer_site": "区块站",
                  "is_proxy": "是否代币", "proxy_symbol": "代币平台", "ico_price_cny": "众筹价格"}
        result={}
        items=doc.css(".secondPark li")
        items.each do |item|
          cell_zh=item.css(".tit").text.delete("：").strip
          cell_name=cell_map.invert[cell_zh].to_s
          puts "====---#{cell_name}"
          case cell_name
          when "name_en"
            result['name_en']=Utils.blank_line_trim(item.css(".value").text)
          when "name_zh"
            result['name_zh']=Utils.blank_line_trim(item.css(".value").text)
          when "on_market_count"
            result['on_market_count']=item.css(".value").text.scan(/\d+/)[0]
          when "pub_at"
            pub_at=Utils.blank_line_trim(item.css(".value").text)
            result['pub_at']=pub_at ? DateTime.parse(pub_at) : nil #发行时间
          when "white_paper"
            result['white_paper']=Utils.blank_line_trim(item.css(".value").text)
          when "website"
            web_items=item.css(".value a")
            web_items.each_with_index do |item, index|
              if index==0
                result['website']=web_items[index]["href"] #网站
              elsif index==1
                result['website2']=web_items[index]["href"] #网站
              end
            end
          when "explorer_site"
            if explorer_items=items.css(".value a") && explorer_items.present?
              result['explorer_site']=explorer_items["href"] #区块站
            end
          when "is_proxy"
            result['is_proxy']=Utils.format_yes_no(Utils.blank_line_trim(item.css(".value").text))
          when "proxy_symbol"
            result['proxy_symbol']=Utils.blank_line_trim(item.css(".value").text)
          when "ico_price_cny" #众筹价格
            ico_text=item.css(".value a").text.gsub("¥", "")
            result['ico_price_cny']=ico_text.to_d if ico_text.match(/\d+/)
          end
        end
        return result
      end
      
      #overriden: 是否覆盖原有数据
      def load_all_wiki(options)
        `echo "">#{Rails.root}/log/feixiaohao.log`
        `echo "">#{Rails.root}/log/feixiaohao_error.log`
        default_opts={overriden: true}
        opts=default_opts.merge(options)
        all_coins=CoinStat
        if opts[:overriden]==false
          all_coins=all_coins.joins("left outer join coin_wikis on coin_stats.symbol=coin_wikis.symbol").where("coin_wikis.id is null")
        end
        all_coins=all_coins.order("coin_stats.curr_market_value desc")
        total_request=all_coins.count
        total_threads=10
        Utils.cal_exc_time("#{total_request}次请求，#{total_threads}个并发") do
          Parallel.each(all_coins, in_threads: total_threads) do |coin|
            ActiveRecord::Base.connection_pool.with_connection do
              begin
                html_result=Utils.fetch_get("https://www.feixiaohao.com/currencies/#{coin.fxh_symbol}", {}, {info: coin.symbol, logger: $logger, file_cache: false})
              rescue => e
                $logger.error(e.message)
                next
              end
              puts "===####11111#{html_result}"
              # cache_path="#{Rails.root}/scripts/templates/fxh_coin.html"
              # html_result=File.read(tmp_path)
              begin
                result=parse_wiki(html_result)
              rescue => e
                $logger.error("解析错误#{coin.symbol}==>#{e.message}")
                puts Utils.format_exception(e)
              end
              puts "===####rrrr#{result}"
              #获取详细信息
              begin
                html_result=Utils.fetch_get("https://www.feixiaohao.com/coindetails/#{coin.fxh_symbol}", {}, {info: coin.symbol, logger: $logger})
              rescue => e
                $logger.error(e.message)
                next
              end
              begin
                doc=Nokogiri::HTML(html_result)
                desc=doc.css(".artBox").text.gsub("\u00A0", '')
                result['desc']=desc.strip
                puts "结果数据：#{result}"
              rescue => e
                $logger.error("解析2错误#{coin.symbol}==>#{e.message}")
                puts Utils.format_exception(e)
              end
              con_wiki=CoinWiki.where(symbol: coin.symbol).first_or_initialize
              con_wiki.attributes=result
              con_wiki.save!
            end
          end
        end
      end
      
      
      ##获取货币市场信息
      def parse_market_list(html)
        doc=Nokogiri::HTML(html)
        doc.css(".plantList li").each_with_index do |row, index|
          result={}
          result["name"]=row.css(".tit").text.strip
          tit=row.css(".tit a") && row.css(".tit a")[0]['href']
          result["code"]=tit && tit.split("/")[-1]
          result["desc"]=row.css(".des").text
          result["exchange_count"]=row.css(".detal a")[0].text
          result["country_name"]=row.css(".detal a")[1].text
          result["country_code"]=row.css(".detal a")[1]["href"].split("?")[-1].split("=")[-1]
          result["amount24"]=Utils.convert_zh_price(row.css(".detal a")[4].text)
          result["currency"]="CNY"
          star=row.css(".tit .star") && row.css(".tit .star")[0]["class"]
          result["star"]=star && star.split(" ")[-1].scan(/\d+/)[0]
          result["tag_str"]=row.css(".tag a i").map { |item| item["title"].delete("支持") }.join(",")
          puts "============== #{result}"
          market=Market.where(code: result["code"]).first_or_initialize
          market.attributes=result
          market.save!
        end
      end
      
      def load_market_by_page(page)
        url="https://www.feixiaohao.com/exchange/list_#{page}.html?filter=star"
        begin
          html_result=Utils.fetch_get(url, {}, {info: "文章"})
        rescue => e
          $logger.error(e.message)
        end
        parse_market_list(html_result)
        #更新排名
        Market.order("amount24 desc").each_with_index do |market, index|
          market.update(rank: index+1)
        end
        # "https://www.feixiaohao.com/exchange/binance/"
      end
      
      
      def load_all_market
        # page=1
        Parallel.map(1..15, in_threads: 5) do |page|
          ActiveRecord::Base.connection_pool.with_connection do
            begin
              load_market_by_page(page)
            rescue Exception => e
              puts Utils.format_exception(e)
            end
          end
        end
      end
      
      
      def parse_market_coins(html, initData=false)
        doc=Nokogiri::HTML(html)
        results=[]
        doc.css("tbody tr").each_with_index do |row, index|
          result={}
          result["symbol_zh"]=row.css("td")[1].text.split("-")[0].strip
          result["fxh_symbol"]=row.css("td")[1].css("a")[0]["href"].split(/\//)[-1].strip
          result["exchange_way"]=row.css("td")[2].text
          result["symbol"]=result["exchange_way"].split("/")[0]
          result["exchange_symbol"]=result["exchange_way"].split("/")[-1]
          result["price"]=Utils.convert_zh_price(row.css("td")[3].text)
          puts "-------#{row.css("td")[4].text}"
          puts "-------22222#{row.css('td')[5].text}"
          result["exchange_count"]=Utils.format_wan_price(row.css("td")[4].text)
          result["exchange_amount"]=Utils.format_wan_price(row.css("td")[5].text)
          puts "=========#{result}"
          results<<result
        end
        results
      end
      
      
      #交易市场支持的货币
      def load_coin_markets(initData=false)
        Parallel.map(Market.order("rank asc").limit(20), in_threads: 5) do |market|
          ActiveRecord::Base.connection_pool.with_connection do
            begin
              url="https://www.feixiaohao.com/exchange/#{market.code}/"
              html_result=Utils.fetch_get(url, {}, {info: ""})
              results=parse_market_coins(html_result, initData)
              results.map do |item|
                item["market_code"]=market.code
                item["market_id"]=market.id
              end
              if initData
                MarketCoin.import!(results)
              else
                results.each do |result|
                  market_coin=MarketCoin.where(market_code: market.code, exchange_way: result["exchange_way"]).first_or_initialize
                  market_coin.attributes=result
                  market_coin.save
                end
              end
            rescue Exception => e
              puts Utils.format_exception(e)
            end
          end
        end
      end
    
    end
  end
end

#测试速度10次请求4秒
#100次请求32秒
#100个请求，15个并发,6秒
#200个请求，15个并发,16-23秒
#500次请求，15个并发,33秒
#=====coin_days================
#=======1603次请求，5个并发，花费时间===3分钟7秒
#=======1591次请求，15个并发，花费时间===10分钟29秒 (初始化数据)
#=======1591次请求，15个并发，花费时间===48秒

#=======1603次请求，15个并发，花费时间===1分钟52秒
#=======1603次请求，15个并发，花费时间===1分钟21秒

#索引性能
#TickerDay Load (567.8ms)  SELECT  `ticker_days`.* FROM `ticker_days` ORDER BY time desc LIMIT 1
#TickerDay Load (15.7ms)  SELECT  `ticker_days`.* FROM `ticker_days` ORDER BY time desc LIMIT 1