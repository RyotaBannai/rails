Rails.application.routes.draw do
  resources :comments, :microposts, :users
  root 'static_pages#home'
  get 'static_pages/home'
  get 'static_pages/help'
  get 'static_pages/about'
end
