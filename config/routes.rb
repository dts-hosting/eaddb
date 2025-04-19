Rails.application.routes.draw do
  resource :session
  root to: "home#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  resources :sources, except: [:new] do
    collection do
      get "new/:type", to: "sources#new", as: "new"
    end
    member do
      post :run
    end
    resources :collections, shallow: true do
      resources :destinations, except: [:new], shallow: true do
        collection do
          get "new/:type", to: "destinations#new", as: "new"
        end
      end
    end
  end

  resources :destinations, only: [:index] do
    member do
      post :run
    end
  end

  resources :records, only: [:index]
end
