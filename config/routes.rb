Rails.application.routes.draw do
  namespace :admin do
    resources :products do
      resources :product_downloads
    end
    resources :product_downloads
  end
end
