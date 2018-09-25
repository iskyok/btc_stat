require 'faraday'
require 'nokogiri'
require 'parallel'
require 'activerecord-import'
# response = Faraday.get "#{BASE_URL}/v2/morecoin?coinType=0&sortType=0&page=1"
BASE_URL="https://mapi.feixiaohao.com"
#  File.open(tmp_path, "wb") do |f|
#   f.puts response.body
# end
$logger = Logger.new("#{Rails.root}/log/feixiaohao_error.log")


def parse_concepts(html)
  doc=Nokogiri::HTML(html)
  results=[]
  doc.css(".tableMain tr").each_with_index do |row, index|
    item={}
    if index>0
      item["name"]=row.css("td")[0].text.strip
      href=row.css("td a")[0]['href']
      puts "========  ===== #{href}"
      item["fxh_source_id"]=href.split("/")[-1].to_i
      results<<item
    end
  end
  results
end

def parse_concept_detail(html)
  doc=Nokogiri::HTML(html)
  results=[]
  doc.css(".tableMain tr").each_with_index do |row, index|
    item={}
    if index>0
      item["symbol"]=row.css("td")[1].text.split("-")[0].strip
      item["full_name"]=row.css("td")[1].text.strip
      results<<item
    end
  end
  results
end

def load_all_concepts(init_data=false)
  begin
    url="https://m.feixiaohao.com/concept/"
    html_result=Utils.fetch_get(url, {}, {info: ""})
    concepts=parse_concepts(html_result)
    if init_data
      Concept.import!(concepts)
    else
      concepts.each do |concept|
        Concept.find_or_create_by(concept)
      end
    end
    
    concepts=Concept.where("fxh_source_id is not null")
    Parallel.map(concepts, in_threads: 5) do |concept|
      ActiveRecord::Base.connection_pool.with_connection do
        begin
          detail_url="https://m.feixiaohao.com/conceptcoin/#{concept['fxh_source_id']}"
          html_result=Utils.fetch_get(detail_url, {}, {info: ""})
          results=parse_concept_detail(html_result)
          puts "=========3333=======#{results}"
          if init_data
            concept=results.map{|item|item["concept_id"]=concept.id}
            ConceptCoin.import!(results)
          else
            results.each do |coin|
              ConceptCoin.find_or_create_by(concept_id: concept.id,symbol: coin["symbol"])
            end
            concept.update(coin_count: results.size)
          end
        rescue Exception => e
          puts Utils.format_exception(e)
        end
      end
    end
  rescue Exception => e
    puts Utils.format_exception(e)
  end
end

load_all_concepts(false)
# load_coin_markets(true)
#抓取内容
# load_all_coins
#load_all_coin_line
#数据库计算
# update_coin_stat
# update_up_price
# load_all_wiki
# load_all_market

