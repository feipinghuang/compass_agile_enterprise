Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :rulesets do
        resources :business_rules

        member do
          get :export
        end

        collection do
          post :import
        end

      end
    end
  end
end

ErpRules::Engine.routes.draw do
end
