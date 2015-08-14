Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do

      resources :projects, :defaults => { :format => 'json' }
      resources :work_efforts, :defaults => { :format => 'json' }
      resources :work_effort_types, :defaults => { :format => 'json' }
      resources :work_effort_party_assignments, :defaults => { :format => 'json' }
      resources :work_effort_associations, :defaults => { :format => 'json' }

    end
  end

end

ErpWorkEffort::Engine.routes.draw do

  namespace :erp_app do
    namespace :organizer do
      namespace :tasks do

        resources :work_efforts do

          collection do
            get :role_types
            get :work_effort_types
            get :task_count
          end

        end

      end #tasks
    end #organizer
  end #erp_app

end
