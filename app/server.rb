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
