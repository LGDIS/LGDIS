# encoding: utf-8
RedmineApp::Application.routes.draw do
  # 避難所開設機能
  resources :projects do
    match '/shelters/:id/delete'  => 'shelters#destroy',     :via => :get
    match '/shelters/search'      => 'shelters#index',       :via => :get
    match '/shelters/search'      => 'shelters#index',       :via => :post
    match '/shelters/bulk_update' => 'shelters#bulk_update', :via => :post
    match '/shelters/ticket'      => 'shelters#ticket',      :via => :post
    match '/shelters/summary'     => 'shelters#summary',     :via => :post
    resources :shelters, :except => [:show, :index]

  # 避難勧告･指示
    match '/evacuation_advisories/:id/delete'  => 'evacuation_advisories#destroy',     :via => :get
    match '/evacuation_advisories/search'      => 'evacuation_advisories#index',       :via => :get
    match '/evacuation_advisories/search'      => 'evacuation_advisories#index',       :via => :post
    match '/evacuation_advisories/bulk_update' => 'evacuation_advisories#bulk_update', :via => :post
    match '/evacuation_advisories/ticket'      => 'evacuation_advisories#ticket',      :via => :post
    match '/evacuation_advisories/summary'     => 'evacuation_advisories#summary',     :via => :post
    resources :evacuation_advisories, :except => [:show, :index]

  end
  resources :deliver_issues do
    get "deliver_issues/index"
  end
  post "deliver_issues/request_delivery"
  post "deliver_issues/allow_delivery"
end
