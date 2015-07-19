Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do

      resources :product_types

    end
  end

end

ErpProducts::Engine.routes.draw do

  namespace 'shared' do
    resources :product_features, except: [:show]
    get '/product_features/get_values' => 'product_features#get_values'
  end

end