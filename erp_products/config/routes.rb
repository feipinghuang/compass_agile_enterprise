Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do

      resources :product_types, defaults: { :format => 'json' } do
        collection do
          get :get_variant_for_selections
        end
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

      resources :discounts, defaults: { :format => 'json' } do
        collection do
          post :add_products_to_discount
          delete :remove_products_from_discount
        end
      end

      resources :collections, defaults: { :format => 'json' } do
        collection do
          post :add_products_to_collection
          delete :remove_products_from_collection
        end
      end

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
