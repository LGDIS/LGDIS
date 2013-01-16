# encoding: utf-8
class Constant < ActiveRecord::Base
  attr_accessible :kind1, :kind2, :kind3, :text, :value, :_order
  
  # コンスタントテーブル取得処理
  # ==== Args
  # _table_name_ :: テーブル名
  # ==== Return
  # コンスタントオブジェクト
  # ==== Raise
  def self.hash_for_table(table_name)
    constant_list = {}
    constant = Constant.find(:all,
    :conditions => ["kind1=? AND kind2=?", 'TD', table_name],
    :order => "kind3 ASC, _order ASC")
    constant.each do |c|
      constant_list[c.kind3] = {} unless constant_list[c.kind3]
      constant_list[c.kind3][c.value] = c.text
    end
    return constant_list
  end
end
