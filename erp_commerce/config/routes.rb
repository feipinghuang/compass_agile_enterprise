Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      resources :parties, defaults: {:format => 'json'} do
        resources :credit_cards, defaults: {:format => 'json'}
        resources :bank_accounts, defaults: {:format => 'json'}
      end

      resources :pricing_plans, defaults: {:format => 'json'} do
        resources :pricing_plan_assignments, defaults: {:format => 'json'}
      end

      resources :pricing_plan_assignments, defaults: {:format => 'json'}

    end
  end
end

ErpCommerce::Engine.routes.draw do
end
