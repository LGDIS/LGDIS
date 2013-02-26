# encoding: utf-8
require "resque"
require "resque/failure/multiple"
require "resque/failure/redis"

Resque.redis = 'localhost:6379'

Resque::Failure::Multiple.configure do |multi|
  multi.classes = [
      Resque::Failure::Redis,
      ExtOut::JobFailureNotification  # Lgdis 外部出力 I/F エラー処理
    ]
end

# workerプロセスで同じjobを複数回実行させる場合に、
# ２回目以降のJobのDBクエリ発行時にPG:ERRORが発生してしまう不具合の対処
# See:: https://github.com/gitlabhq/gitlabhq/issues/2197
Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
