# -*- encoding: utf-8 -*-
class CreateIssuesAddtionData < ActiveRecord::Migration
  def change
    create_table :issues_addtion_data do |t|
			t.integer :id
			t.integer :issue_id
			t.string	:geodetic_datum
			t.decimal :latitude, :precision => 13, :scale => 8
			t.decimal :longitude, :precision => 13, :scale => 8
			t.string	:address
			t.string	:remarks
#       t.decimal :point
#       t.decimal :line
#       t.decimal :polygon
    end
		set_table_comment(:issues_addtion_data, "チケット追加データ")
		set_column_comment(:issues_addtion_data , :id,					   "ID")
		set_column_comment(:issues_addtion_data , :issue_id,		   "チケット番号")
		set_column_comment(:issues_addtion_data , :geodetic_datum, "測地系")
		set_column_comment(:issues_addtion_data , :latitude,       "緯度")
		set_column_comment(:issues_addtion_data , :longitude,      "経度")
		set_column_comment(:issues_addtion_data , :address,        "住所")
		set_column_comment(:issues_addtion_data , :remarks,        "備考")
#     set_column_comment(:issues_addtion_data , :point,      "point")
#     set_column_comment(:issues_addtion_data , :line,      "line")
#     set_column_comment(:issues_addtion_data , :polygon,      "polygon")
  end
end
