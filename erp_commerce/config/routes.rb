Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      resources :parties, defaults: {:format => 'json'} do
        resources :credit_cards, defaults: {:format => 'json'}
      end

    end
  end
end

ErpCommerce::Engine.routes.draw do
end
