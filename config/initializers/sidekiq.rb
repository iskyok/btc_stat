require 'sidekiq'
require 'sidekiq/web'
Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == '' && password == ''
end

# if Rails.env.development? or Rails.env.test?
#   redis_config = {
#     :url => "redis://#{REDIS_CONFIG['host']}:#{REDIS_CONFIG['port']}/0"
#   }
# else
#   redis_config = {
#     :url => "redis://#{REDIS_CONFIG['host']}:#{REDIS_CONFIG['port']}/0"
#   }
# end
#
# Sidekiq.configure_client do |config|
#   config.redis = redis_config
# end


# Sidekiq.options[:poll_interval] = 10

Sidekiq::Cron::Job.create(name: 'DayLineWorker - every 5min', cron: '*/5 * * * *', class: 'DayLineWorker')
# execute at every 5 minutes, ex: 12:05, 12:10, 12:15...etc
