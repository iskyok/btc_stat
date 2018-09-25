class CoinsController < ApplicationController
  
  #curl http://localhost:4000/api/coins/all_coins
  def all_coins
    filters = filter_params.merge(order_params)
    @coins=CoinStat
    @coins = @coins.where(symbol: filters[:symbol]) if filters[:symbol].present?
    @coins = @coins.where("pub_at >= ?", filters[:from_date]) if filters[:from_date].present?
    @coins = @coins.where("pub_at <= ?", filters[:to_date]) if filters[:to_date].present?
    @coins = @coins.find_by_price_range("curr_market_value", params[:market_value_range].split(",")) if params[:market_value_range].present?
    @coins = @coins.where("curr_price <=pub_price") if filters[:is_break]
    @coins = @coins.joins(:concept_coins).where("concept_coins.concept_id=?",params[:concept_id]) if filters[:concept_id]

    @coins = @coins.includes(:wiki).order(filters[:order].join(' ')).page(params[:page]).per(params[:per_page]||50)
    latest_ticker_time=TickerDay.order("time desc").first.time
    render json: {coins: @coins.as_json(coins_json), meta: meta_attributes(@coins).merge({per_page: params[:per_page]||50}), latest_updated_at: latest_ticker_time}
  end
  
  def all_filter
    @coins=CoinStat
    ranges=[1000, 500, 100, 50, 10, 1, 0.5, 0.2, 0.1, 0.05, 0.01].map { |price| price * 10**8 }
    sql_ranges=Utils.get_price_range(ranges, "curr_market_value")
    sql_ranges.map do |item|
      item[:count]=@coins.where(item.delete("sql")).count
    end
    render json: {marketValueRanges: sql_ranges}
  end
  
  def show
    @coin=CoinStat.where(symbol: params[:id]).first
    @coin_wiki=CoinWiki.where(symbol: params[:id]).first
    attrs=@coin.attributes.merge!(full_name: @coin.full_name, curr_price_cny: @coin.curr_price_cny,
                                  curr_ico_times: @coin.curr_ico_times,
                                  curr_trade_volume_cny: @coin.curr_trade_volume_cny,
                                  current_trade_per: @coin.current_trade_per,
                                  trade24_amount_cny: @coin.trade24_amount_cny,
                                  curr_market_value_cny: @coin.curr_market_value_cny,
                                  pub_price_cny: @coin.pub_price_cny
    )
    result=@coin && @coin_wiki ? attrs.merge!(@coin_wiki.attributes) : attrs
    render json: result
  end
  
  def dash_coins
  
  end
  
  def market_exchanges
    @market_coins=MarketCoin.where(symbol: params[:id])
    @market_coins=@market_coins.joins(:market).order("markets.rank asc")
    @market_coins=@market_coins.page(params[:page]).per(params[:per_page]||15)
    render json: {market_coins: @market_coins.as_json(market_coins_json), meta: meta_attributes(@market_coins)}
  end
  
  def filter_params
    filters = params.permit(:symbol,:concept_id, :is_break, :star_level, :from_date, :to_date).delete_if { |_, v| v.blank? }
    filters[:to_date] = (Date.parse(params[:to_date]) rescue Date.current).end_of_day unless filters[:to_date].blank?
    filters
  end
  
  def order_params
    # 排序字段
    sort_fields = %w[symbol pub_price  price_updated_at curr_price max_up_per curr_up_per curr_hour24_up curr_market_value]
    sort = params[:order].to_s.downcase.split(' ').map(&:strip)
    if sort_fields.include?(sort.first) && %w[asc desc].include?(sort.last)
      {order: [sort.first.to_sym, sort.last.to_sym]}
    else
      {order: %i[curr_market_value desc]}
    end
  end
  
  private
  
  
  def coins_json
    {only: ["symbol", "curr_price", "price_updated_at","curr_market_value", "curr_hour24_up", "pub_at", "pub_price", "max_up_per", "curr_up_per"],
     methods: ["summary","curr_price_cny", "pub_price_cny", "curr_market_value_cny","full_name"]}
  end
  
  def market_coins_json
    {methods: [:market_name,:market_rank,:exchange_amount_cny,:exchange_count_unit,:price_unit]}
  end
end
