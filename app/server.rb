# frozen_string_literal: true

require 'rack'
require 'sinatra/base'
require 'sinatra/reloader'
require 'sequel'

require_relative 'models'

class Server < Sinatra::Base
  configure do
    set :public_folder, "#{__dir__}/static"
  end

  get '/' do
    content_type 'text/html'
    erb :index, locals: { message: 'Welcome<br> To <br>Null Island<br>' }
  end

  get '/api/links' do
    return unauthorized unless valid_token? request

    content_type 'application/json'
    Links.all.map(&:values).to_json
  end

  get '/api/books' do
    return unauthorized unless valid_token? request

    content_type 'application/json'
    Books.all.map(&:values).to_json
  end

  not_found do
    status 404
    erb :not_found
  end

  def unauthorized
    status 401
    erb :not_allow
  end

  def valid_token?(request)
    token = request.env['HTTP_AUTHORIZATION']
    token == ENV['SECRET_TOKEN']
  end
end
