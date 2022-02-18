# frozen_string_literal: true

require 'rack'
require 'sinatra/base'
require 'sinatra/reloader'
require 'sequel'
require 'twilio-ruby'

require_relative 'models'

class Server < Sinatra::Base
  use Rack::TwilioWebhookAuthentication, ENV['TWILIO_AUTH_TOKEN'], '/twilio'

  configure do
    set :public_folder, "#{__dir__}/static"
  end

  get '/' do
    content_type 'text/html'
    erb :index, locals: { message: 'Welcome<br> To <br>Null Island<br>' }
  end

  get '/home' do
    markdown '#Testing ##this works'
  end

  get '/api/pressure_reading' do
    return unauthorized unless valid_token? request

    content_type 'application/json'
    PressureReading.all.map(&:values).to_json
  end

  post '/api/pressure_reading' do
    return unauthorized unless valid_token? request

    PressureReading.create(**request.params)
    201
  end

  delete '/api/pressure_reading/:id' do |id|
    PressureReading[id]&.delete
    200
  end

  post '/twilio/message' do
    content_type 'text/xml'
    if params['Body'][0..3].match?(/[0-9]+/)
      systolic, diastolic = params['Body'].split(',')
      PressureReading.create(systolic: systolic, diastolic: diastolic)
      message = 'Saved'
    elsif params['Body'].casecmp('last')
      reading = PressureReading.order(:created_at).last
      message = "#{reading.systolic}/#{reading.diastolic}"
    end
    response = Twilio::TwiML::MessagingResponse.new
    response.message(body: message)
    response.to_s
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
