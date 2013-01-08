# encoding: utf-8
require 'redmine'
require_dependency 'lgdis/issues_helper_patch'
require_dependency 'lgdis/view_hooks'
#require_dependency 'lgdis/show_view_hooks' # Viewホックポイントの確認用
require_dependency 'lgdis/ext_out/twitter'
require_dependency 'lgdis/ext_out/facebook'

Redmine::Plugin.register :lgdis do
  name 'Local Gavament Disaster Infomation System (Lgdis) plugin'
  author '作成者XXX'
  description '災害発生時における地方公共団体向けの包括的メッセージング:Local Gavament Disaster Infomation System (Lgdis) をRedmineに追加するプラグインです。'
  version '0.0.1'

  project_module :shelters do
    permission :view_shelters, :shelters => [:index, :edit]
    permission :manage_shelters, :shelters => [:new, :create, :update, :destroy]
  end
  menu :project_menu, :shelters, { :controller => 'shelters', :action => 'index' }, :caption => :label_shelter, :after => :new_issue, :param => :project_id

  ActiveSupport::Dependencies.autoload_paths += %W(#{Rails.root}/plugins/lgdis/lib/validators)

  # API キー設定ファイルロード
  API_KEY = YAML.load_file("#{Rails.root}/plugins/lgdis/config/api_key.yml")
end
