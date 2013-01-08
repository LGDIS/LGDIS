# encoding: utf-8
Dir.glob File.expand_path(Rails.root.join("plugins/*/db/seeds.rb"), __FILE__) do |file|
  instance_eval File.read(file)
end