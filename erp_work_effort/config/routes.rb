Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do

      # projects and its nested resources
      resources :projects, :defaults => { :format => 'json' } do
        resources :work_efforts, :defaults => { :format => 'json' }
        resources :work_effort_party_assignments, :defaults => { :format => 'json' }
        resources :work_effort_associations, :defaults => { :format => 'json' }
      end

      # work efforts and its nested resources
      resources :work_efforts, :defaults => { :format => 'json' } do
        resources :work_effort_party_assignments, :defaults => { :format => 'json' }
      end

      resources :work_effort_party_assignments, :defaults => { :format => 'json' }
      resources :work_effort_associations, :defaults => { :format => 'json' }

      # types
      resources :work_effort_types, :defaults => { :format => 'json' }

      resources :time_entries, :defaults => { :format => 'json' }
    end
  end

end
