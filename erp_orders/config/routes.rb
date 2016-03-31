Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do

      resources :order_txns, defaults: { :format => 'json' }

      resources :order_line_items, defaults: { :format => 'json' }

    end
  end

end

ErpOrders::Engine.routes.draw do
end


