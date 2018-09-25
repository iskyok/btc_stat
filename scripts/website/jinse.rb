require 'nokogiri'
require 'parallel'
require 'activerecord-import'

def load_feeds_by_limit(offset, init_data)
  begin
    json_result=Utils.fetch_get("http://www.jinse.com/ajax/lives/getList?search=&id=#{offset}&flag=down", {}, {info: "文章"})
  rescue => e
    $logger.error(e.message)
  end
  parse_data(json_result, init_data)
end


def format_publish_time(date)
  begin
    publish_time=DateTime.parse(date)
  rescue
    publish_time=nil
  end
  publish_time
end

def parse_data(json_result, init_data)
  data=JSON.parse json_result
  data["data"].each do |date, items|
    
    results=items.map { |item| {content: item["content"], up_point: item["up_counts"], down_point: item["down_counts"],
                                source_url: item["source_url"],
                                link: item["link"],
                                link_name: item["name"],
                                star: item["grade"],
                                website: item["website"],
                                source_id: item["id"],
                                publish_time: format_publish_time(item["publish_time"]),
                                created_at: date+" "+item["created_at"],
                                updated_at: date+" "+item["updated_at"]}
    }
    if init_data
      CoinFeed.import!(results)
    else
      results.each do |item|
        puts "=====#{item}"
        feed=CoinFeed.where(source_id: item[:source_id]).first_or_initialize
        feed.attributes=item
        feed.save!
      end
    end
  end
end


def load_feeds(init_data=false)
  # begin
  html_result=Utils.fetch_get("http://www.jinse.com/lives", {}, {info: "文章"})
  # rescue => e
  #   $logger.error(e.message)
  # end
  doc=Nokogiri::HTML(html_result)
  latest_offset=doc.css(".lost li")[0]["data-id"].to_i+1
  per_page=20
  if init_data # 初始化数据
    #total_pages=490 #自定义总请求页数
    total_pages=latest_offset/per_page #当前全部页数
    offset_range=(latest_offset-total_pages*per_page).step(latest_offset, per_page).to_a
  else
    curr_latest_feed=CoinFeed.order("source_id desc").first
    current_offset=curr_latest_feed.source_id
    offset_range=(current_offset).step(latest_offset, per_page).to_a<<latest_offset
  end
  puts "===>#{offset_range.to_a}"
  puts "最新偏移量#{latest_offset}===当前偏移#{current_offset}==获取总页数：#{offset_range.size}==每页:#{per_page}==结果：#{offset_range}"
  total_threads=10
  if latest_offset && offset_range.to_a.size>0
    Utils.cal_exc_time("#{offset_range.to_a.size}次请求，#{total_threads}个并发") do
      Parallel.map(offset_range.to_a, in_threads: total_threads) do |limit|
        ActiveRecord::Base.connection_pool.with_connection do
          load_feeds_by_limit(limit, init_data)
        end
      end
    end
  end
end

begin
  load_feeds(false)
rescue => e
  puts "====#{Utils.format_exception(e)}"
end

