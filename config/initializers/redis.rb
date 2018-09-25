require "redis"
$redis = Redis.new(:host => REDIS_CONFIG["host"],:port => REDIS_CONFIG["port"])
