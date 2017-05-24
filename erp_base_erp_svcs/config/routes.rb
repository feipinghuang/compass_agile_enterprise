Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      resources :parties, defaults: { :format => 'json' } do
        member do
          put :update_roles
          get :related_parties
        end

        resources :role_types, defaults: { :format => 'json' }
        resources :email_addresses, defaults: { :format => 'json' }
        resources :phone_numbers, defaults: { :format => 'json' }
        resources :postal_addresses, defaults: { :format => 'json' }
      end

      resources :tracked_status_types, defaults: { :format => 'json' }
      resources :role_types, defaults: { :format => 'json' }
      resources :note_types, defaults: { :format => 'json' }
      resources :categories, defaults: { :format => 'json' }
      resources :contact_purposes, defaults: { :format => 'json' }
      resources :geo_zones, defaults: { :format => 'json' }
      resources :status_applications, defaults: { :format => 'json' }
      resources :unit_of_measurements, defaults: { :format => 'json' }
      resources :email_addresses, defaults: { :format => 'json' }
      resources :phone_numbers, defaults: { :format => 'json' }
      resources :postal_addresses, defaults: { :format => 'json' }
      resources :facilities, defaults: { :format => 'json' }
    end
  end

end

ErpBaseErpSvcs::Engine.routes.draw do

  namespace 'shared' do
    resources 'units_of_measurement'
  end

end
