# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'

configure do
  set :default_content_type, :json
  set :public_folder, "#{__dir__}/static"
end

get '/' do
  content_type 'text/html'
  erb :index, locals: { message: 'Welcome<br>To<br>Null Island<br>' }
end
