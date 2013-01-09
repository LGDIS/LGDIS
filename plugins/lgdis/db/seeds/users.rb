# encoding: utf-8
# 削除（idが1より大きい 且つ 100以下 ※1はadminユーザ）
ActiveRecord::Base.connection.execute(%{DELETE FROM users WHERE id> 1 and id<= 100})

# シーケンス初期化（100以下の場合のみ）
ActiveRecord::Base.connection.execute(%{SELECT setval( 'users_id_seq' ,CASE WHEN (SELECT MAX(id) FROM users) >= 100 THEN (SELECT MAX(id) FROM users) ELSE 100 END)})

Group.create(id: "2", name: "サンプル2")
