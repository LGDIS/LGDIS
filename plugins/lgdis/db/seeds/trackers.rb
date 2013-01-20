# encoding: utf-8
# 削除（100以下）
ActiveRecord::Base.connection.execute(%{DELETE FROM trackers WHERE id <= 100})

# シーケンス初期化（100以下の場合のみ）
ActiveRecord::Base.connection.execute(%{SELECT setval( 'trackers_id_seq' ,CASE WHEN (SELECT MAX(id) FROM trackers) >= 100 THEN (SELECT MAX(id) FROM trackers) ELSE 100 END)})

# 登録
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (1, 1, '避難勧告・指示情報（公共情報コモンズ配信用）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (2, 30, '避難勧告・指示情報（APPLIC配信用）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (3, 2, '避難所情報（公共情報コモンズ配信用）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (4, 31, '避難所情報（APPLIC配信用）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (5, 3, 'JMA（気象等環境変化）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (6, 4, 'JMA（警報・注意報）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (7, 5, '河川情報（気象等環境変化）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (8, 6, '河川情報（警報・注意報）', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (9, 32, '被害状況_詳細情報(APPLIC配信用）', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (10, 7, '人的被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (11, 8, '住家建物被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (12, 33, '非住家建物被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (13, 9, '道路被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (14, 10, '橋梁被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (15, 11, '上水道被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (16, 12, '下水道被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (17, 13, 'ガス設備被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (18, 14, '通信網被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (19, 34, '高等学校被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (20, 35, '中学校被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (21, 36, '小学校被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (22, 37, '幼稚園被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (23, 38, '保育所被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (24, 39, '災害弱者関連施設被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (25, 40, '医療施設被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (26, 41, '災害重要施設被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (27, 15, 'その他被害報告', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (28, 16, '災害対策本部設置状況', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (29, 17, '被害要約報告（被害概況即報）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (30, 18, '被害要約報告（被害状況即報）', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (31, 19, '地震・津波発生情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (32, 20, '通行規制情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (33, 21, '渋滞情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (34, 22, '交通事故情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (35, 23, '故障者情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (36, 24, '路上障害物情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (37, 25, '工事情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (38, 26, '火災情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (39, 27, '路面状況情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (40, 42, '鉄道・バス運行情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (41, 43, '上水道復旧情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (42, 44, '下水道復旧情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (43, 45, 'ガス復旧情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (44, 46, '通信網復旧情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (45, 47, 'その他情報', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (46, 28, '災害関連要望', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (47, 29, '物資資材調達', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (48, 48, '一般情報', false, true, 0)})
