# require 'eu_central_bank'
# eu_bank = EuCentralBank.new
# Money.default_bank = eu_bank
# eu_bank.save_rates(Rails.root.to_s+"/db/eu_central_bank.xml")
# eu_bank.update_rates

# require 'money/bank/google_currency'
# Money::Bank::GoogleCurrency.ttl_in_seconds = 86400
# google_bank=Money::Bank::GoogleCurrency.new
# Money.default_bank =google_bank
# google_bank.save_rates(Rails.root.to_s+"/db/google_bank.xml")
# google_bank.update_rates

require 'money'
require 'money/bank/currencylayer'

Money::Bank::Currencylayer.ttl_in_seconds = 3600*7 # 7 hours ttl
Money::Bank::Currencylayer.rates_careful = true
# bank = Money::Bank::Currencylayer.new
bank = Money::Bank::Currencylayer.new {|n| n.round(4)} # round result to 4 digits after point
bank.access_key = 'fc34cdcb43ea6a5055fcf2e7f3035dbc'

# set default bank to instance
Money.default_bank = bank
Money.infinite_precision = true