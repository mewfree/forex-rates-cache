require 'net/http'
require 'redis'
require 'sinatra'

redis = Redis.new(:url => ENV['REDIS_URL'])

uri = URI('https://openexchangerates.org/api/latest.json?app_id='+ENV['OER_ID'])

if redis.get('forexrates').nil?
  data = Net::HTTP.get(uri)
  redis.setex('forexrates', ENV['TTL'], data)
else
  data = redis.get('forexrates')
end

get '/' do
  data
end
