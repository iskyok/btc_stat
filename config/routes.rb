Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope :api do
    resources :coins do
      collection do
        get :all_coins, :all_dash
        get :all_filter
      end
      member do
        get :market_exchanges
      end
    end
    
    resources :feeds
    resources :markets do
      collection do
        get :all_counties
      end
      member do
        get :market_exchanges
      end
    end
    
    resources :concepts do
      collection do
        get :all_concepts
      end
    end
    
    resources :companies
  end
  
  require 'sidekiq/web'
  # require 'sidekiq-scheduler/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web, at: '/sidekiq'
end