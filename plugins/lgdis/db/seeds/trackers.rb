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
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (5, 3, '気象情報（気象等環境変化）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (6, 4, '気象情報（警報・注意報）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (7, 5, '河川情報（気象等環境変化）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (8, 6, '河川情報（警報・注意報）', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (9, 16, '【消防庁様式】災害対策本部設置報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (10, 17, '【消防庁様式】被害要約報告（概況）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (11, 18, '【消防庁様式】被害要約報告（状況）', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (12, 7, '【被害報告】人的', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (13, 8, '【被害報告】住家建物', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (14, 33, '【被害報告】非住家建物', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (15, 9, '【被害報告】道路', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (16, 10, '【被害報告】橋梁', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (17, 11, '【被害報告】上水道', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (18, 12, '【被害報告】下水道', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (19, 13, '【被害報告】ガス設備', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (20, 14, '【被害報告】通信網', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (21, 34, '【被害報告】高等学校', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (22, 35, '【被害報告】中学校', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (23, 36, '【被害報告】小学校', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (24, 37, '【被害報告】幼稚園', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (25, 38, '【被害報告】保育所', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (26, 39, '【被害報告】災害弱者関連施設', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (27, 40, '【被害報告】医療施設', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (28, 41, '【被害報告】災害重要施設', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (29, 15, '【被害報告】その他', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (32, 20, '道路通行規制情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (33, 21, '道路渋滞情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (34, 22, '道路交通事故情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (35, 23, '路上故障車情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (36, 24, '路上障害物情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (37, 25, '道路工事情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (38, 26, '道路火災情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (39, 27, '道路路面状況情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (40, 42, '鉄道・バス運行情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (41, 43, '上水道復旧情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (42, 44, '下水道復旧情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (43, 45, 'ガス復旧情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (44, 46, '通信網復旧情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (45, 47, 'その他情報', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (46, 28, '災害関連要望', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (47, 29, '物資資材調達', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (48, 48, '一般情報', false, true, 0)})
