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
  end
  resources :deliver_issues do
    get "deliver_issues/index"
    get "deliver_issues/show"
  end

  resources :delivery_histories do
    get "delivery_histories/index"
  end
  post "deliver_issues/request_delivery"
  post "deliver_issues/allow_delivery"
end
