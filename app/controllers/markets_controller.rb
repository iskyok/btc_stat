class MarketsController < ApplicationController
  
  #curl http://localhost:4000/api/feeds/all_feeds
  def index
    filters = filter_params.merge(order_params)
    @markets=Market
    @markets = @markets.where(symbol: filters[:symbol]) if filters[:symbol].present?
    @markets = @markets.find_star_range(filters[:star_level]) if filters[:star_level].present?
    @markets = @markets.where(country_code: filters[:country_code]) if filters[:country_code].present?
    @markets = @markets.where("created_at >= ?", filters[:from_date]) if filters[:from_date].present?
    @markets = @markets.where("created_at <= ?", filters[:to_date]) if filters[:to_date].present?
    @markets = @markets.order(filters[:order].join(' ')).page(params[:page]).per(params[:per_page])
    render json: {markets: @markets.as_json(makets_json), meta: meta_attributes(@markets)}
  end
  
  def show
    @market=Market.find_by(code: params[:id])
    render json: @market.as_json
  end

  def market_exchanges
    @market_coins=MarketCoin.where(market_code: params[:id]).page(params[:page]).per(params[:per_page]||15)
    render json: {market_coins: @market_coins.as_json(market_coins_json), meta: meta_attributes(@market_coins)}
  end

  def all_counties
    countries=Country.order("market_count desc")
    render json: {contries: countries}
  end
  
  def filter_params
    filters = params.permit(:symbol,:country_code, :star_level, :from_date, :to_date).delete_if { |_, v| v.blank? }
    filters[:to_date] = (Date.parse(params[:to_date]) rescue Date.current).end_of_day unless filters[:to_date].blank?
    filters
  end
  
  def order_params
    # 排序字段
    sort_fields = %w[symbol pub_price curr_price max_up_per curr_up_per curr_hour24_up curr_market_value]
    sort = params[:order].to_s.downcase.split(' ').map(&:strip)
    if sort_fields.include?(sort.first) && %w[asc desc].include?(sort.last)
      {order: [sort.first.to_sym, sort.last.to_sym]}
    else
      {order: %i[rank asc]}
    end
  end
  
  def makets_json
    {methods: [:amount24_cny]}
  end

  def market_coins_json
    {methods: [:market_name,:exchange_amount_cny]
    }
  end
end
