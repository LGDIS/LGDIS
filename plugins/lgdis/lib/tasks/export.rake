# -*- coding: utf-8 -*-
namespace :export do

  desc "dump shelters to file(csv) for LGDPM/LGDPF."
  task :shelters => :environment do
    Rails.logger.info " #{Time.now} ===== START ===== "
    Rails.logger.info Batches::ExportShelters.execute
    Rails.logger.info " #{Time.now} =====  END  ===== "
  end
end
