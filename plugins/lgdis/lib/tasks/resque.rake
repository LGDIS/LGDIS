require "resque/tasks"
# TODO
# resque-scheduler 対応
# require 'resque_scheduler/tasks'

task "resque:setup" => :environment
