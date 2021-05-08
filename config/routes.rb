Rails.application.routes.draw do
  mount Raddocs::App => "/"

  namespace :v1, defaults: { format: :json } do
    resources :registrations, only: :create
    resources :tokens, only: :create
    resource :profile, only: %i[show update destroy]
    resources :users, only: %i[index show]
    resources :articles, only: %i[index show create update]
    resources :comments, only: %i[index show create update]
    resources :subscriptions, only: %i[index show create destroy]
    resources :likes, only: %i[index create destroy]
    resources :progress_informations, only: %i[index show create update]
    resources :subscribed_progress_informations, only: :index
  end
end
