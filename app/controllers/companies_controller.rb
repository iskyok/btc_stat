class CompaniesController < ApplicationController
  
  #curl http://localhost:4000/api/feeds/all_feeds
  def index
    filters = filter_params.merge(order_params)
    @companies=Company.all
    @companies = @companies.where(symbol: filters[:symbol]) if filters[:symbol].present?
    @companies = @companies.find_star_range(filters[:star_level]) if filters[:star_level].present?
    @companies = @companies.where(country_code: filters[:country_code]) if filters[:country_code].present?
    @companies = @companies.where("created_at >= ?", filters[:from_date]) if filters[:from_date].present?
    @companies = @companies.where("created_at <= ?", filters[:to_date]) if filters[:to_date].present?
    @companies = @companies.order(filters[:order].join(' ')).page(params[:page]).per(params[:per_page])
    render json: {companies: @companies.as_json(companies_json), meta: meta_attributes(@companies)}
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
      {order: %i[id desc]}
    end
  end
  
  def companies_json
    {methods: ["full_name","country_name"],include: [coin_invests: {only: [:name,:symbol,:company_id]}]}
  end
end
