class ConceptsController < ApplicationController
  
  #curl http://localhost:4000/api/feeds/all_feeds
  
  def all_concepts
    concepts=Concept.order("coin_count desc")
    render json: {concepts: concepts.as_json({only: [:id,:name,:coin_count]})}
  end

end
