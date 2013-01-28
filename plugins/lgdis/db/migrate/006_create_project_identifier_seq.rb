# -*- coding:utf-8 -*-
class CreateProjectIdentifierSeq < ActiveRecord::Migration
  def up
    # 最大値:15桁
    execute "CREATE SEQUENCE project_identifier_seq maxvalue 999999999999999"
  end
  def down
    execute "DROP SEQUENCE project_identifier_seq"
  end
end
