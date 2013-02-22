# -*- coding:utf-8 -*-
# バッチの実行コマンド
# rails runner Batches::MemcacheStore.execute
# ==== options
# 実行環境の指定 :: -e production
require 'csv'

class Batches::MemcacheStore
  def self.execute
    p " #{Time.now.to_s} ===== START ===== "
    
    store("area")
    
    p " #{Time.now.to_s} =====  END  ===== "
  end
  
  def self.store(file)
    r = CSV.open("#{Rails.root}/plugins/lgdis/lib/batches/#{file}.csv", "r", encoding: "utf-8")
    h = Hash.new
    header = r.take(1)[0]
    r.each do |row|
      h.store(row[0], Hash[*header.zip(row).flatten])
    end
    Rails.cache.write(file, h)
  end
end
