Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :biz_txn_types, defaults: { :format => 'json' }
      resources :biz_txn_events, defaults: { :format => 'json' }
      resources :biz_txn_acct_roots, defaults: { :format => 'json' }
      resources :biz_txn_acct_types, defaults: { :format => 'json' }
      resources :financial_txns, defaults: { :format => 'json' }
    end
  end

end

ErpTxnsAndAccts::Engine.routes.draw do
end
