class Concept < ApplicationRecord
  has_many :concept_coins,class_name: "ConceptCoin"
  has_many :coins,through: "concept_coins" ,foreign_key: "symbol"
  
end
