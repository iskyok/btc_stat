class ConceptCoin < ApplicationRecord
  has_one :coin,class_name: "CoinStat",foreign_key: "symbol",primary_key: "symbol"
end
