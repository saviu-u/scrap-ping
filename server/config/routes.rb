Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'home#index'

  get '/search/:search', to: 'search#search'
  get '/search', to: 'search#search'

  resources :products, only: :show
end
