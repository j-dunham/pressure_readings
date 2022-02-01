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
    if valid_token? request
      status 200
      content_type 'application/json'
      Links.all.map(&:values).to_json
    else
      status 401
      erb :not_allow
    end
  end

  not_found do
    status 404
    erb :not_found
  end

  def valid_token?(request)
    token = request.env['HTTP_AUTHORIZATION']
    token == ENV['SECRET_TOKEN']
  end
end
