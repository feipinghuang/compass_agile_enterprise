Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do

      resources :invoices, :defaults => {:format => 'json'}

    end # v1
  end # api

end

ErpInvoicing::Engine.routes.draw do
end