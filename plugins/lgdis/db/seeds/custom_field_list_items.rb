# encoding: utf-8
require 'csv'
settings = YAML.load_file(File.join(Rails.root,"plugins","lgdis","config","custom_field_list_items.yml"))
settings["load_settings"].each {|custom_field_id, load_setting|
  file_name, row_num = load_setting[0..1]
  item_values = []
  CSV.foreach(File.join(settings["load_dir"], file_name), encoding: "UTF-8") do |row|
    next if row.count < 1 # 空行はスキップ
    item_values << row[row_num]
  end
  if item_values.present? && icf = IssueCustomField.find_by_id(custom_field_id)
    # カスタムフィールドリスト項目の選択肢の設定
    icf.update_attributes(possible_values: item_values)
  end
}
