require 'redis'
require 'json'

unless ARGV.length == 2
  p "Usage: #{$0} username topic"
  exit 1
end

username = ARGV[0]
topic = ARGV[1]

Thread.new do
  Redis.new.subscribe(topic) do |on|
    p "Joined ##{topic}"
    on.message do |channel, msg|
      data = JSON.parse(msg)
      puts "[#{data['user']}]: #{data['msg']}"
    end
  end
end

$redis = Redis.new

loop do
  msg = STDIN.gets
  $redis.publish topic, {user: username, msg: msg}.to_json
end
