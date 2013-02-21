# encoding: utf-8
Constant.delete_all # 全件削除

# Seed-data for Model 'Shelter' by Hayashi-san
# 避難所種別
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'shelter_type', text: '避難所',                    value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'shelter_type', text: '臨時避難所',                value: '2', _order: '2')
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'shelter_type', text: '広域避難所：開設措置なし',  value: '3', _order: '3')
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'shelter_type', text: '一次避難所：開設措置なし',  value: '4', _order: '4')
# 避難所区分
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'shelter_sort', text: '未開設', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'shelter_sort', text: '開設',   value: '2', _order: '2')
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'shelter_sort', text: '閉鎖',   value: '3', _order: '3')
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'shelter_sort', text: '不明',   value: '4', _order: '4')
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'shelter_sort', text: '常設',   value: '5', _order: '5')
# 避難所状況
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'status', text: '空き',      value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'status', text: '混雑',      value: '2', _order: '2')
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'status', text: '定員一杯',  value: '3', _order: '3')
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'status', text: '不明',      value: '4', _order: '4')
# 使用可否
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'usable_flag', text: '可',      value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'usable_flag', text: '不可',    value: '0', _order: '2')
# 開設の可否
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'openable_flag', text: '可',    value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'shelters', kind3: 'openable_flag', text: '不可',  value: '0', _order: '2')

# 避難勧告･指示モデル' 
# 発令・解除区分 
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'issue_or_lift', text: '発令',      value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'issue_or_lift', text: '解除',      value: '0', _order: '2')
# 地区（大分類）
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'district', text: '石巻地区',   value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'district', text: '河北地区',   value: '2', _order: '2')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'district', text: '雄勝地区',   value: '3', _order: '3')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'district', text: '河南地区',   value: '4', _order: '4')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'district', text: '桃生地区',   value: '5', _order: '5')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'district', text: '北上地区',   value: '6', _order: '6')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'district', text: '牡鹿地区',   value: '7', _order: '7')
# COMMONSむけ発令区分
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'sort_criteria', text: '指示等なし', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'sort_criteria', text: '避難準備',   value: '2', _order: '2')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'sort_criteria', text: '避難勧告',   value: '3', _order: '3')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'sort_criteria', text: '避難指示',   value: '4', _order: '4')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'sort_criteria', text: '警戒区域',   value: '5', _order: '5')
# APPLIC互換 避難勧告･指示種別
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'advisory_type', text: '1 避難準備', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'advisory_type', text: '2 避難勧告', value: '2', _order: '2')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'advisory_type', text: '3 避難指示', value: '3', _order: '3')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'advisory_type', text: '4 自主避難', value: '4', _order: '4')
# APPLIC互換 災害区分
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '01 台風', value: '01', _order: '1')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '02 暴風', value: '02', _order: '2')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '03 豪雨', value: '03', _order: '3')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '04 降雪', value: '04', _order: '4')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '05 洪水', value: '05', _order: '5')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '06 高潮', value: '06', _order: '6')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '07 地震', value: '07', _order: '7')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '08 津波', value: '08', _order: '8')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '09 火災', value: '09', _order: '9')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '10 爆発', value: '10', _order: '10')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '11 噴火', value: '11', _order: '11')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '12 雷害', value: '12', _order: '12')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '13 落雷', value: '13', _order: '13')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '14 地滑り等', value: '14', _order: '14')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '15 竜巻', value: '15', _order: '15')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '16 強風', value: '16', _order: '16')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '17 その他嵐', value: '17', _order: '17')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '18 干ばつ', value: '18', _order: '18')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '19 異常高温', value: '19', _order: '19')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '20 異常低温', value: '20', _order: '20')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '21 非熱帯サイクロン', value: '21', _order: '21')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '22 鉄砲水', value: '22', _order: '22')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '23 雪崩', value: '23', _order: '23')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '24 泥流', value: '24', _order: '24')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '25 地震火災', value: '25', _order: '25')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '26 森林火災', value: '26', _order: '26')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '27 伝染病', value: '27', _order: '27')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '28 虫害', value: '28', _order: '28')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '29 その他自然災害', value: '29', _order: '29')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '30 複合災害', value: '30', _order: '30')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '31 人為災害', value: '31', _order: '31')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '32 その他', value: '32', _order: '32')
Constant.create(kind1: 'TD', kind2: 'evacuation_advisories', kind3: 'category', text: '99 未定義災害', value: '32', _order: '99')

# 災害被害情報モデル
# 災害対策本部等設置状況_市町村_本部種別
Constant.create(kind1: 'TD', kind2: 'disaster_damages', kind3: 'municipal_antidisaster_headquarter_type', text: '警戒本部', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'disaster_damages', kind3: 'municipal_antidisaster_headquarter_type', text: '対策本部', value: '2', _order: '2')
# 災害対策本部等設置状況_市町村
Constant.create(kind1: 'TD', kind2: 'disaster_damages', kind3: 'municipal_antidisaster_headquarter_status', text: '解散', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'disaster_damages', kind3: 'municipal_antidisaster_headquarter_status', text: '設置', value: '2', _order: '2')

# コントロールプレーン部
# 要因
Constant.create(kind1: 'TD', kind2: 'issues', kind3: 'xml_control_cause', text: '正規', value: '0', _order: '1')
Constant.create(kind1: 'TD', kind2: 'issues', kind3: 'xml_control_cause', text: '訂正', value: '1', _order: '2')
Constant.create(kind1: 'TD', kind2: 'issues', kind3: 'xml_control_cause', text: '訓練', value: '2', _order: '3')
Constant.create(kind1: 'TD', kind2: 'issues', kind3: 'xml_control_cause', text: '削除', value: '3', _order: '4')
# 承認
Constant.create(kind1: 'TD', kind2: 'issues', kind3: 'xml_control_apply', text: '未', value: '0', _order: '1')
Constant.create(kind1: 'TD', kind2: 'issues', kind3: 'xml_control_apply', text: '済', value: '1', _order: '2')
# 情報の更新種別
Constant.create(kind1: 'TD', kind2: 'issues', kind3: 'type_update', text: '新規', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'issues', kind3: 'type_update', text: '更新', value: '2', _order: '2')
Constant.create(kind1: 'TD', kind2: 'issues', kind3: 'type_update', text: '取消', value: '3', _order: '3')
# TODO
# seed とするかcache とするか確認
# 情報の配信対象地域(仮想データ)
Constant.create(kind1: 'TD', kind2: 'issues', kind3: 'delivered_area', text: '石巻市', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'issues', kind3: 'delivered_area', text: '仙台市', value: '2', _order: '2')

