# -*- coding:utf-8 -*-
require 'redmine'

# OmniAuth
# ActiveSupport::Dependencies.autoload_pathsではconst_missingが発生しないとロードされないため、明示的にロードする
require "#{Rails.root}/plugins/lgdis/config/initializers/omniauth"

# 非同期処理
ActiveSupport::Dependencies.autoload_paths += %W(#{Rails.root}/plugins/lgdis/app/workers)
require "#{Rails.root}/plugins/lgdis/config/initializers/resque"

# カスタムバリデータ
ActiveSupport::Dependencies.autoload_paths += %W(#{Rails.root}/plugins/lgdis/lib/validators)

# バッチファイル
ActiveSupport::Dependencies.autoload_paths += %W(#{Rails.root}/plugins/lgdis/lib/batches)

# 設定ファイルロード
API_KEY     = YAML.load_file("#{Rails.root}/plugins/lgdis/config/api_key.yml")
DST_LIST    = YAML.load_file("#{Rails.root}/plugins/lgdis/config/destination_list.yml")
MAP_VALUES  = YAML.load_file("#{Rails.root}/plugins/lgdis/config/issue_map_default_values.yml")
CF_CONNECT  = YAML.load_file("#{Rails.root}/plugins/lgdis/config/custom_field_connection.yml")["custom_field_connection"]
CF_ADDRESS  = YAML.load_file("#{Rails.root}/plugins/lgdis/config/custom_field_connection.yml")
STATISTICS_SQL  = YAML.load_file("#{Rails.root}/plugins/lgdis/config/statistics_sql_query.yml")
EVACUATIONADVISORY_MAP = YAML.load_file("#{Rails.root}/plugins/lgdis/config/evacuation_advisory.yml")
VERSION     = YAML.load_file("#{Rails.root}/plugins/lgdis/config/version.yml")
SETTINGS    = YAML.load_file("#{Rails.root}/plugins/lgdis/config/lgdis.yml")
ZNETTOWN    = YAML.load_file("#{Rails.root}/plugins/lgdis/config/znettown_key.yml")

# library, plugin
require_dependency 'lgdis/acts/acts_as_mode_switchable'
require_dependency 'lgdis/acts/acts_as_csv_creatable'
require_dependency 'lgdis/acts/acts_as_customizable_patch'

# helper
require_dependency 'lgdis/application_helper_patch'
require_dependency 'lgdis/custom_fields_helper_patch'
require_dependency 'lgdis/issues_helper_patch' # issues_controller_patch より先にload する必要あり

# model
require_dependency 'lgdis/custom_field_patch'
require_dependency 'lgdis/project_patch'
require_dependency 'lgdis/user_patch'
require_dependency 'lgdis/issue_patch'
require_dependency 'lgdis/mailer_patch'

# controller
require_dependency 'lgdis/welcome_controller_patch'
require_dependency 'lgdis/account_controller_patch'
require_dependency 'lgdis/issues_controller_patch'
require_dependency 'lgdis/controller_hooks'

# view
require_dependency 'lgdis/view_hooks'
#require_dependency 'lgdis/show_view_hooks' # Viewホックポイントの確認用

Redmine::Plugin.register :lgdis do
  name 'LGDIS (Local Government Disaster Information System) plugin'
  author '作成者XXX'
  description '災害発生時における地方公共団体向けの包括的メッセージング:LGDIS (Local Government Disaster Information System) をRedmineに追加するプラグインです。'
  version VERSION["version"]

  # トップメニュー/ホームの削除
  Redmine::MenuManager.map :top_menu do |menu|
    menu.delete :home
  end

  # トップメニュー/マニュアルの削除・上書き
  Redmine::MenuManager.map :top_menu do |menu|
    menu.delete :help
    
    manual_url = SETTINGS["manual_url"]
    unless /\Ahttp/ =~ manual_url
      prefix = ENV['RAILS_RELATIVE_URL_ROOT'].to_s
      manual_url = prefix + manual_url
    end
    
    menu.push :help, manual_url, :last => true
  end

  # トップメニュー/アカウント登録の削除
  Redmine::MenuManager.map :account_menu do |menu|
    menu.delete :register
  end

  # プロジェクトメニュー/チケット・新しいチケットを概要の次に配置
  Redmine::MenuManager.map :project_menu do |menu|
    menu.delete :issues
    menu.delete :new_issue
    menu.push :issues, { :controller => 'issues', :action => 'index' }, :param => :project_id, :caption => :label_issue_plural, :after => :overview
    menu.push :new_issue, { :controller => 'issues', :action => 'new' }, :param => :project_id, :caption => :label_issue_new,
                :html => { :accesskey => Redmine::AccessKeys.key_for(:new_issue) }, :after => :issues
  end

  # 避難勧告・指示
  project_module :evacuation_advisories do
    permission :view_evacuation_advisories, :evacuation_advisories => [:index, :edit]
    permission :manage_evacuation_advisories, :evacuation_advisories => [:new, :create, :update, :destroy, :bulk_update, :ticket, :summary]
  end
  menu :project_menu, :evacuation_advisories, { :controller => 'evacuation_advisories', :action => 'index' }, :caption => :label_evacuation_advisory, :after => :new_issue, :param => :project_id

  # 避難所開設
  project_module :shelters do
    permission :view_shelters, :shelters => [:index, :edit]
    permission :manage_shelters, :shelters => [:new, :create, :update, :destroy, :bulk_update, :ticket]
  end
  menu :project_menu, :shelters, { :controller => 'shelters', :action => 'index' }, :caption => :label_shelter, :after => :evacuation_advisories, :param => :project_id

  # 災害被害情報（第４号様式）
  project_module :disaster_damage do
    permission :view_disaster_damage, :disaster_damage => [:index]
    permission :manage_disaster_damage, :disaster_damage => [:save, :ticket]
  end
  menu :project_menu, :disaster_damage, { :controller => 'disaster_damage', :action => 'index' }, :caption => :label_disaster_damage, :after => :shelters, :param => :project_id

  # 配信管理
  project_module :delivery_histories do
    permission :request_delivery, :delivery_histories => [:index]
  end
  menu :project_menu, :delivery_histories, { :controller => 'delivery_histories', :action => 'index' }, :caption => :project_module_deliver, :after => :disaster_damage, :param => :project_id

  # プラグイン設定
  settings :default => {
    :enable_external_auth => true,
    :term_auto_launch_project => 7,
    :issue_xml_visible => false
  }, :partial => 'settings/lgdis'
end
