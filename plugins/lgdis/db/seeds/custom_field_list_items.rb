# encoding: utf-8
require 'csv'
settings = YAML.load_file(File.join(Rails.root,"plugins","lgdis","config","custom_field_list_items.yml"))
settings["load_settings"].each {|custom_field_id, load_setting|
  file_name, row_nums, default_value_row_num = load_setting[0..2]
  item_values, default_values = nil, []
  CSV.foreach(File.join(settings["load_dir"], file_name), encoding: "UTF-8") do |row|
    next if row.count < 1 # 空行はスキップ
    item_value_array = []
    (row_nums.is_a?(Array) ? row_nums : [row_nums]).each do |row_num|
      item_value_array << row[row_num]
    end
    item_value = item_value_array.join(":") # 各列値を:区切の文字列で格納
    (item_values ||= []) << item_value
    default_values << item_value if row[default_value_row_num].to_s == "1"
  end
  if item_values.present? && icf = IssueCustomField.find_by_id(custom_field_id)
    raise "カスタムフィールド書式がリストではありません。" +
          "[カスタムフィールドID:#{custom_field_id}, ファイル名:#{file_name}]" unless icf.field_format == 'list'
    # カスタムフィールドリスト項目の選択肢の設定
    icf.possible_values = item_values
    # カスタムフィールドリスト項目のデフォルト値の設定
    raise "複数選択可ではないカスタムフィールドに、デフォルト値を複数個設定しています。" +
          "[カスタムフィールドID:#{custom_field_id}, ファイル名:#{file_name}]" if default_values.count > 1 && !icf.multiple?
    default_values = default_values.first unless icf.multiple?
    icf.default_value = default_values
    icf.save!
  end
}
