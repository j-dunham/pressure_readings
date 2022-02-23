# frozen_string_literal: true

require 'rack'
require 'sinatra/base'
require 'sinatra/reloader'
require 'sequel'
require 'bcrypt'

require_relative '../db/models'

class AppController < Sinatra::Base
  configure do
    register Sinatra::Reloader if development?

    enable :sessions
    set :public_folder, 'app/static'
    set :views, 'app/views'
  end

  helpers do
    def current_username
      session[:username]
    end

    def current_user_id
      session[:user_id]
    end

    def valid_token?(request)
      request.env['HTTP_AUTHORIZATION'] == ENV['SECRET_TOKEN']
    end
  end

  get '/' do
    content_type 'text/html'
    @message = "Welcome<br>#{current_username}"
    erb :index, { locals: { is_logged_in: !current_username.nil? } }
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    @user = User.where(username: params[:username]).first
    if @user && BCrypt::Password.new(@user.password) == params[:password]
      session[:username] = @user.username
      session[:user_id] = @user.id
      redirect '/'
    end

    @message = 'Nope..'
    erb :login
  end

  get '/logout' do
    session.clearr
    redirect '/'
  end

  get '/raise_error' do
    raise StandardError
  end

  not_found do
    status 404
    erb :not_found
  end

  def unauthorized
    status 401
    erb :not_allow
  end
end
