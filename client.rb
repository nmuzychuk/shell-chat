require 'redis'
require 'json'

unless ARGV.length == 2
  puts "Usage: #{$0} username topic"
  exit 1
end

username = ARGV[0]
topic = ARGV[1]

$sub = Redis.new
Thread.new do
  $sub.subscribe(topic) do |on|
    puts "Joined ##{topic}"
    on.message do |_channel, msg|
      data = JSON.parse(msg)
      unless username == data['user']
        puts "[#{data['user']}]: #{data['msg']}    (#{Time.at(data['time'])})"
      end
    end
  end
end

$redis = Redis.new

Signal.trap("SIGINT") do
  puts "\nQuitting..."
  $sub.close
  $redis.close
  exit
end

loop do
  msg = STDIN.gets
  time = Time.now.to_i
  $redis.publish topic, {user: username, msg: msg, time: time}.to_json
  puts "    (#{Time.at(time)})"
end
