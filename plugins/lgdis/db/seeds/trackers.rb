# encoding: utf-8
# 削除（100以下）
ActiveRecord::Base.connection.execute(%{DELETE FROM trackers WHERE id <= 100})

# シーケンス初期化（100以下の場合のみ）
ActiveRecord::Base.connection.execute(%{SELECT setval( 'trackers_id_seq' ,CASE WHEN (SELECT MAX(id) FROM trackers) >= 100 THEN (SELECT MAX(id) FROM trackers) ELSE 100 END)})

# 登録
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (1, 1, '避難勧告・指示情報（公共情報コモンズ配信用）', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (2, 2, '避難所情報（公共情報コモンズ配信用）', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (3, 3, 'JMA（気象等環境変化）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (4, 4, 'JMA（警報・注意報）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (5, 5, '河川情報（気象等環境変化）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (6, 6, '河川情報（警報・注意報）', false, true, 0)})


ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (7, 7, '人的被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (8, 8, '建物被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (9, 9, '道路被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (10, 10, '橋梁被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (11, 11, '上水道被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (12, 12, '下水道被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (13, 13, 'ガス設備被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (14, 14, '通信網被害報告', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (15, 15, 'その他被害報告', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (16, 16, '災害対策本部設置状況', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (17, 17, '被害要約報告（被害概況即報）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (18, 18, '被害要約報告（被害状況即報）', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (19, 19, '地震・津波発生情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (20, 20, '通行規制情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (21, 21, '渋滞情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (22, 22, '交通事故情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (23, 23, '故障者情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (24, 24, '路上障害物情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (25, 25, '工事情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (26, 26, '火災情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (27, 27, '路面状況情報', false, true, 0)})




ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (28, 28, '災害関連要望', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (29, 29, '物資資材調達', false, true, 0)})
