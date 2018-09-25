class ExchangeUpWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :common, :retry => 0

  def perform
    Parallel.map(CoinStat.all, in_threads: 15) do |coin|
      ActiveRecord::Base.connection_pool.with_connection do
       coin.update({curr_hour1_up: coin.hour1_up,curr_hour24_up: coin.hour24_up,
                    curr_day7_up: coin.day7_up
                   })
      end
    end
  end
end