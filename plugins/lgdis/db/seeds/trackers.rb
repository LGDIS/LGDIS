# encoding: utf-8
# 削除（100以下）
ActiveRecord::Base.connection.execute(%{DELETE FROM trackers WHERE id <= 100})

# シーケンス初期化（100以下の場合のみ）
ActiveRecord::Base.connection.execute(%{SELECT setval( 'trackers_id_seq' ,CASE WHEN (SELECT MAX(id) FROM trackers) >= 100 THEN (SELECT MAX(id) FROM trackers) ELSE 100 END)})

# 登録
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (1, 77, '【システム】J-ALERT 発信（内閣官房）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (2, 78, '【システム】J-ALERT 発信（気象庁）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (3, 4, '【システム】気象庁発信（警報・注意報）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (4, 3, '【システム】気象庁発信（その他）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (5, 6, '【システム】河川管理者発信（警報・注意報）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (6, 5, '【システム】河川管理者発信（その他）', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (7, 16, '【システム】災害対策本部設置', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (8, 1, '【システム】避難勧告・指示', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (9, 2, '【システム】避難所開設・閉鎖', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (10, 17, '【システム】被害要約（概況）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (11, 18, '【システム】被害要約（状況）', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (12, 7, '【被害報告】人的', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (13, 8, '【被害報告】住家建物', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (14, 33, '【被害報告】非住家建物', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (15, 9, '【被害報告】道路', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (16, 10, '【被害報告】橋梁', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (17, 76, '【被害報告】電気', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (18, 11, '【被害報告】上水道', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (19, 12, '【被害報告】下水道', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (20, 13, '【被害報告】ガス設備', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (21, 14, '【被害報告】通信網', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (22, 34, '【被害報告】高等学校', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (23, 35, '【被害報告】中学校', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (24, 36, '【被害報告】小学校', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (25, 37, '【被害報告】幼稚園', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (26, 38, '【被害報告】保育所', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (27, 39, '【被害報告】災害弱者関連施設', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (28, 40, '【被害報告】医療施設', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (29, 41, '【被害報告】災害重要施設', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (30, 15, '【被害報告】その他', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (31, 22, '道路交通事故に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (32, 23, '路上故障車に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (33, 24, '路上障害物に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (34, 26, '道路火災に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (35, 67, '火災・救急・救助の要請', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (36, 68, '海上に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (37, 69, '河川に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (38, 70, '広域圏災害に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (39, 28, '被災者からの要望（生活全般）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (40, 71, '被災者からの要望（食料）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (41, 29, '被災者からの要望（物資・資材）', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (42, 48, 'その他の災害関連情報', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (43, 20, '【広報-交通】道路通行規制に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (44, 21, '【広報-交通】道路渋滞に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (45, 25, '【広報-交通】道路工事に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (46, 27, '【広報-交通】道路路面状況に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (47, 42, '【広報-交通】鉄道の運行に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (48, 72, '【広報-交通】バスの運行に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (49, 73, '【広報-交通】航空路の運行に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (50, 74, '【広報-交通】船舶路の運行に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (51, 75, '【広報-交通】その他公共交通の運行に関する情報', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (52, 55, '【広報-ライフライン】給水に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (53, 50, '【広報-ライフライン】電気に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (54, 43, '【広報-ライフライン】上水道に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (55, 44, '【広報-ライフライン】下水道に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (56, 45, '【広報-ライフライン】ガスに関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (57, 46, '【広報-ライフライン】通信網に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (58, 51, '【広報-ライフライン】臨時災害放送に関する情報', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (59, 52, '【広報-生活情報】行政手続きに関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (60, 62, '【広報-生活情報】安置所に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (61, 63, '【広報-生活情報】災害拾得物に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (62, 60, '【広報-生活情報】炊き出し・物資配布に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (63, 61, '【広報-生活情報】入浴サービスに関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (64, 66, '【広報-生活情報】営業店舗に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (65, 59, '【広報-生活情報】医療に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (66, 56, '【広報-生活情報】健康・福祉・介護に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (67, 54, '【広報-生活情報】学校・幼稚園・保育所に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (68, 57, '【広報-生活情報】環境に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (69, 58, '【広報-生活情報】防犯に関する情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (70, 64, '【広報-生活情報】ボランティアの支援を受けたい方への情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (71, 65, '【広報-生活情報】ボランティア活動をしたい方への情報', false, true, 0)})
ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (72, 53, '【広報-生活情報】その他の被災者支援に関する情報', false, true, 0)})

ActiveRecord::Base.connection.execute(%{INSERT INTO trackers (position, id, name, is_in_chlog, is_in_roadmap, fields_bits) VALUES (73, 79, '【システム】公共情報コモンズ発信（緊急速報メール配信結果）', false, true, 0)})

ActiveRecord::Base.connection.execute(%{UPDATE trackers set fields_bits = 206})
