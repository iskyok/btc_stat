class DayLineWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :common, :retry => 0

  def perform
    puts "======sssss"
    CoinApi::Feixiaohao.load_all_coin_line
  end
end
#
# class DayLineItemWorker
#   include Sidekiq::Worker
#   sidekiq_options :queue => :common, :retry => 3
#
#   def perform
#     CoinApi::Feixiaohao.load_all_coin_line
#     self.class.perform_in(5.minutes)
#   end
# end
