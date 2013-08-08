# encoding: utf-8
# システム管理者(admin)ユーザの設定
admin = User.find(1)
# 言語：Japanese (日本語:LGDIS)
admin.update_attributes!(language: "ja-LG")


# 設定/表示
# 既定の言語：Japanese (日本語:LGDIS)
Setting.default_language = "ja-LG"
# ユーザー名の表示書式：姓 名
Setting.user_format = "lastname_firstname"

# 設定/認証
# 認証が必要：true
Setting.login_required = 1
# ユーザーによるアカウント登録：メールでアカウントを有効化
Setting.self_registration = 1
# ユーザーによるアカウント削除を許可：false
Setting.unsubscribe = 0
# パスワードの再発行：false
Setting.lost_password = 0
# RESTによるWebサービスを有効にする：true
Setting.rest_api_enabled = 1

# 設定/プロジェクト
# デフォルトで新しいプロジェクトは公開にする：false
Setting.default_projects_public = 0
# 新規プロジェクトにおいてデフォルトで有効になるモジュール：チケットトラッキング,避難所開設機能
Setting.default_projects_modules = ["issue_tracking", "shelters", "delivery_histories", "evacuation_advisories", "disaster_damage"]

# 設定/メール通知
# 送信元メールアドレス：
Setting.mail_from = 'no-reply@example.com'
