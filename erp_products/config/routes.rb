Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do

      resources :product_types, defaults: { :format => 'json' } do
        resources :product_option_applicabilities, defaults: { :format => 'json' } do
          collection do
            put :update_positions
          end
        end
      end
      resources :product_option_types, defaults: { :format => 'json' } do
        resources :product_options, defaults: { :format => 'json' }
      end
      resources :product_option_applicabilities, defaults: { :format => 'json' } do
        collection do
          put :update_positions
        end
      end

      resources :discounts, defaults: { :format => 'json' }
      resources :collections, defaults: { :format => 'json' }
      resources :product_offers, defaults: { :format => 'json' }
      resources :product_options, defaults: { :format => 'json' }
      resources :selected_product_options, defaults: { :format => 'json' }
    end
  end

end

ErpProducts::Engine.routes.draw do

  namespace 'shared' do
    resources :product_features, except: [:show]
    get '/product_features/get_values' => 'product_features#get_values'
  end

end
