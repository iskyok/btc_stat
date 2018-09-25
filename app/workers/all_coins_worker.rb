class AllCoinsWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :common, :retry => 0
  
  def perform
    puts "======sssss"
    CoinApi::Feixiaohao.load_all_coins
  end
end