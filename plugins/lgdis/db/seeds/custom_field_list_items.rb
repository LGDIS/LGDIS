# encoding: utf-8
settings = YAML.load_file(File.join(Rails.root,"plugins","lgdis","config","custom_field_list_items.yml"))
settings["load_settings"].each {|custom_field_id, file_name|
  item_values = []
  File.foreach(File.join(settings["load_dir"], file_name)) {|line| item_values << line.chomp.gsub(/,/, ":")}
  if item_values.present? && icf = IssueCustomField.find_by_id(custom_field_id)
    #p "#{custom_field_id}:#{icf.name} <<< #{file_name}"
    # カスタムフィールドリスト項目の選択肢の設定
    icf.update_attributes(possible_values: item_values)
  end
}
