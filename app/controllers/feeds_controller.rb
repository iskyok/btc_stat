class FeedsController < ApplicationController
  
  #curl http://localhost:4000/api/feeds/all_feeds
  def index
    filters = filter_params.merge(order_params)
    @feeds=CoinFeed
    @feeds = @feeds.where(symbol: filters[:symbol]) if filters[:symbol].present?
    @feeds = @feeds.find_star_range(filters[:star_level]) if filters[:star_level].present?
    @feeds = @feeds.where("created_at >= ?", filters[:from_date]) if filters[:from_date].present?
    @feeds = @feeds.where("created_at <= ?", filters[:to_date]) if filters[:to_date].present?
    @feeds = @feeds.order(filters[:order].join(' ')).page(params[:page]).per(params[:per_page])
    render json: {feeds: @feeds.as_json(feeds_json), meta: meta_attributes(@feeds)}
  end
  
  
  def filter_params
    filters = params.permit(:symbol,:star_level, :from_date, :to_date).delete_if { |_, v| v.blank? }
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
      {order: %i[created_at desc]}
    end
  end
  
  def feeds_json
    {}
  end
end
