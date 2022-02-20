# frozen_string_literal: true

require 'rack'
require 'sinatra/base'
require 'sinatra/reloader'
require 'sequel'
require 'bcrypt'

require_relative '../db/models'

class AppController < Sinatra::Base
  configure do
    enable :sessions
    set :public_folder, 'app/static'
    set :views, 'app/views'
  end

  get '/' do
    content_type 'text/html'
    @is_logged_in = !session[:username].nil?
    @message = 'Welcome<br> To <br>Null Island<br>'
    erb :index
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    @user = User.where(username: params[:username]).first
    if @user && BCrypt::Password.new(@user.password) == params[:password]
      session[:username] = @user.username
      redirect '/'
    end

    @message = 'Not Found..'
    erb :login
  end

  get '/logout' do
    session.clear
    redirect '/'
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
