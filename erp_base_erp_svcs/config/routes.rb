Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      resources :parties do
        member do
          put :update_roles
        end
      end
      resources :role_types
      resources :note_types
      resources :categories
      resources :contact_purposes
      resources :geo_zones
    end
  end

end

ErpBaseErpSvcs::Engine.routes.draw do

  namespace 'shared' do
    resources 'units_of_measurement'
  end

end
