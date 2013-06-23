# encoding: utf-8
RedmineApp::Application.routes.draw do
  match "/auth/:provider"          => "omniauth_callbacks#error", :via => [:get, :post]
  match "/auth/:provider/callback" => "omniauth_callbacks#auth",  :via => [:get, :post]

  resources :projects do
    # 避難所開設機能
    match '/shelters/:id/delete'  => 'shelters#destroy',     :via => :get
    match '/shelters/search'      => 'shelters#index',       :via => :get
    match '/shelters/search'      => 'shelters#index',       :via => :post
    match '/shelters/bulk_update' => 'shelters#bulk_update', :via => :post
    match '/shelters/ticket'      => 'shelters#ticket',      :via => :post
    resources :shelters, :except => [:show]

    # 避難勧告･指示
    match '/evacuation_advisories/:id/delete'  => 'evacuation_advisories#destroy',     :via => :get
    match '/evacuation_advisories/search'      => 'evacuation_advisories#index',       :via => :get
    match '/evacuation_advisories/search'      => 'evacuation_advisories#index',       :via => :post
    match '/evacuation_advisories/bulk_update' => 'evacuation_advisories#bulk_update', :via => :post
    match '/evacuation_advisories/ticket'      => 'evacuation_advisories#ticket',      :via => :post
    resources :evacuation_advisories, :except => [:show, :index]

    # 災害被害情報（第４号様式）機能
    match '/disaster_damage'        => 'disaster_damage#index',   :via => [:get,:post,:put]
    match '/disaster_damage/:id'        => 'disaster_damage#show',   :via => :get

    # 配信管理機能 配信一覧
    resources :delivery_histories, :only => [:index]
  end

  # 配信管理機能
  resources :deliver_issues do
    get "deliver_issues/index"
  end

  # 最新プロジェクトID取得
  get "delivery_project/getproject/" => "delivery_project#getproject"

  match "/issues/:id/request_delivery" => "issues#request_delivery", :via => :post
  post "deliver_issues/allow_delivery"
end