# encoding: utf-8
Constant.delete_all # 全件削除

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
