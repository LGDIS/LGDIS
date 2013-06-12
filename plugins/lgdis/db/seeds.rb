# encoding: utf-8

# rake redmine:load_default_data は行われている前提
puts "lgdis plugin's seed executing..."

def import(target)
  seeds_dir_path = "#{Rails.root}/plugins/lgdis/db/seeds"
  puts "importing: #{target}"
  load("#{seeds_dir_path}/#{target}.rb")
end


# コンスタントテーブル
import "constants"

# 地区
import "areas"

# カスタムフィールド
import "custom_fields"
import "custom_field_list_items"

# トラッカー
import "trackers"

# トラッカー <=> カスタムフィールド
import "custom_fields_trackers"

# 各種初期設定
import "default_settings"

# # プロジェクト
import "projects"

# # チケットステータス
import "issue_statuses"

# # ロール
import "roles"

# # グループ
import "groups"

# # ワークフロー(ステータス遷移)
# # TODO: ここに追加する

# # ワークフロー(フィールドに対する権限)
import "workflow_permissions"

# # デフォルトプロジェクトへのグループ設定
#import "groups_to_projects"

puts "finished!"
