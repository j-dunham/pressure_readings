# frozen_string_literal: true

require 'rack'
require 'sinatra/base'
require 'sequel'
require 'twilio-ruby'
require 'bcrypt'

require_relative '../db/models'

class PressureController < AppController
  use Rack::TwilioWebhookAuthentication, ENV['TWILIO_AUTH_TOKEN'], '/twilio'

  get '/list_readings' do
    redirect '/' unless current_username

    @readings = PressureReading.all.reverse

    erb :list_readings
  end

  get '/add_reading' do
    redirect '/' unless current_username

    erb :add_reading
  end

  get '/reading_summary' do
    redirect '/' unless current_username

    @limit = 5
    @systolic_average = PressureReading.reverse(:created_at).limit(@limit).sum(:systolic) / @limit
    @diastolic_average = PressureReading.reverse(:created_at).limit(@limit).sum(:diastolic) / @limit
    erb :read_summary
  end

  post '/pressure_reading' do
    redirect '/' unless current_username

    PressureReading.create(user_id: current_user_id, **request.params)
    redirect :list_readings
  end

  delete '/pressure_reading/:id' do |id|
    redirect '/' unless current_username

    PressureReading[id]&.delete
    redirect :list_readings
  end

  post '/twilio/message' do
    content_type 'text/xml'
    save_reading if save_request?

    twilio_response(message: last_readings(10))
  end

  def twilio_response(message:)
    response = Twilio::TwiML::MessagingResponse.new
    response.message(body: message)
    response.to_s
  end

  def last_readings(limit)
    readings = PressureReading.order(:created_at).limit(limit).reverse
    readings.map { |reading| "#{reading.systolic}/#{reading.diastolic}" }.join(' || ')
  end

  def save_request?
    params['Body'][0..3].match?(/[0-9]+/)
  end

  def save_reading
    systolic, diastolic = params['Body'].split(',')
    PressureReading.create(systolic: systolic, diastolic: diastolic, user_id: ENV['DEFAULT_USER_ID'])
  end
end
