Rails.application.routes.draw do
  resources :rulesets do
    resources :business_rules
  end
end

ErpRules::Engine.routes.draw do
end
