# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'

configure do
  set :public_folder, "#{__dir__}/static"
end

get '/' do
  content_type 'text/html'
  erb :index, locals: { message: 'Welcome<br>To<br>Null Island<br>' }
end

get '/location' do
  content_type 'application/json'
  { 'location' => '0,0' }.to_json
end

not_found do
  status 404
  erb :not_found
end
