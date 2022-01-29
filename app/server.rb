# frozen_string_literal: true

require 'rack'
require 'sinatra'
require 'sinatra/reloader'
require 'dotenv'

Dotenv.load

configure do
  set :public_folder, "#{__dir__}/static"
end

get '/' do
  content_type 'text/html'
  erb :index, locals: { message: 'Welcome<br>To<br>Null Island<br>' }
end

get '/location' do
  status 401
  return erb :not_allow unless validate_token(request)

  status 200
  content_type 'application/json'
  { 'location' => '0,0' }.to_json
end

not_found do
  status 404
  erb :not_found
end

def validate_token(request)
  token = request.env['HTTP_AUTHORIZATION']
  token == ENV['SECRET_TOKEN']
end
