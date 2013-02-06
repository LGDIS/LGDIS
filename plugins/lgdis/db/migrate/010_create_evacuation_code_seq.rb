# -*- coding:utf-8 -*-
class CreateEvacuationCodeSeq < ActiveRecord::Migration
  def up
    # 最大値:14桁
    execute "CREATE SEQUENCE evacuation_code_seq maxvalue 99999999999999"
  end
  def down
    execute "DROP SEQUENCE evacuation_code_seq"
  end
end
