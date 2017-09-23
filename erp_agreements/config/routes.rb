Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

    	resources :agreements
    	resources :agreement_types

    end
  end
end

ErpAgreements::Engine.routes.draw do
end
