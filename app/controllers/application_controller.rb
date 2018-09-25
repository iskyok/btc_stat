class ApplicationController < ActionController::API
  
  
  rescue_from Exception do |e|
    Rails.logger.info e.inspect
    Rails.logger.info e.backtrace.join("\n")
    render json: {error: '服务器错误'}, status: :internal_server_error
  end
  
  rescue_from ActiveRecord::RecordNotFound do |e|
    Rails.logger.info e.inspect
    Rails.logger.info e.backtrace.join("\n")
    render json: {error: '资源不存在'}, status: :not_found
  end


  def api_error(status: 500, error: [])
    head status: status and return if error.blank?
    render json: jsonapi_format(status, error).to_json, status: status
  end

  def jsonapi_format(status, error)
    if error.respond_to?(:full_messages)
      error=error.full_messages.first
    end
    return {status: status, error: error}
  end
  
  def meta_attributes(object)
    {
      current_page: object.current_page,
      total_pages:  object.total_pages,
      total_count:  object.total_count,
      per_page:     params[:per_page]||15
    }
  end

  def database_transaction
    begin
      ActiveRecord::Base.transaction do
        yield
      end
      true
    rescue => e
      logger.error %[#{e.class.to_s} (#{e.message}):\n\n #{e.backtrace.join("\n")}\n\n]
      false
    end
  end
  
end
