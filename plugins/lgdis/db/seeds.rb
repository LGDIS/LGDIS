# encoding: utf-8
p "lgdis plugin's seed executing..."
# rake redmine:load_default_data は行われている前提

seeds_dir_path="#{Rails.root}/plugins/lgdis/db/seeds"

# コンスタントテーブル
load("#{seeds_dir_path}/constants.rb")

# カスタムフィールド
load("#{seeds_dir_path}/custom_fields.rb")
load("#{seeds_dir_path}/custom_field_list_items.rb")

# トラッカー
load("#{seeds_dir_path}/trackers.rb")

# トラッカー <=> カスタムフィールド
load("#{seeds_dir_path}/custom_fields_trackers.rb")

# 各種初期設定
load("#{seeds_dir_path}/default_settings.rb")

p "finished!"
