require "resque/tasks"
require 'resque_scheduler/tasks'

task "resque:setup" => :environment
