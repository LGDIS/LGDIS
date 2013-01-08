# encoding: utf-8
RedmineApp::Application.routes.draw do
  # 避難所開設機能
  resources :projects do
    match '/shelters/:id/delete'       => 'shelters#destroy',    :via => :get
    resources :shelters, :except => [:show]
  end
end