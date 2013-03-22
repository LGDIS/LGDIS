# -*- coding:utf-8 -*-
# バッチの実行コマンド
# rails runner Batches::ExportShelters.execute

require 'csv'

class Batches::ExportShelters < ActiveRecord::Base

  FILE_PREFIX = "_xA9z94_"
  EXPORT_TARGET = "#{Rails.root}/public/exportdata/"

  def self.execute
    output_file = Pathname(EXPORT_TARGET) + "#{FILE_PREFIX}#{Rails.env}.csv"
    begin
      puts "environment: #{Rails.env}"
      Dir::mkdir(EXPORT_TARGET) unless File.exist?(EXPORT_TARGET)
      Shelter.transaction do
        CSV.open(output_file, "w", csv_option) do |csv_writer|
          Shelter.order(:id).all.each do |row|
            csv_writer << ActiveSupport::JSON.decode(row.to_json)["shelter"]
          end
        end
        rows_count = Shelter.count
        puts " exported.(#{rows_count} rows)"
      end
    rescue => e
      File.delete(output_file) if File.exist?(output_file)
      puts "ERROR: #{e.class}: #{e.message}"
    end
  end

  def self.csv_option
    {
      :encoding => "UTF-8",
      :headers => ActiveSupport::JSON.decode(Shelter.new.to_json)["shelter"].map{|k,v| k},
      :quote_char => '"',
      :write_headers => true,
      :force_quotes => true,
    }
  end
end
