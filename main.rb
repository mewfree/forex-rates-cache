require 'net/http'
require 'redis'
require 'sinatra'
require 'json'

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

def convert(data, amount, from, to)
  fx = JSON.parse(data)
  if fx['rates'].include? from and fx['rates'].include? to
    usd = amount.to_f / fx['rates'][from]
    return usd * fx['rates'][to]
  else
    return 'Currency not supported'
  end
end

get '/convert/:amount/:from/:to' do
  convert(data, params['amount'], params['from'], params['to']).to_s
end
