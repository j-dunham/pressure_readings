# frozen_string_literal: true

require 'rack'
require 'sinatra/base'
require 'sequel'
require 'twilio-ruby'
require 'bcrypt'

require_relative '../db/models'

class PressureController < AppController
  use Rack::TwilioWebhookAuthentication, ENV['TWILIO_AUTH_TOKEN'], '/twilio'

  get '/pressure_readings' do
    redirect '/' unless current_user

    @readings = PressureReading.all

    erb :readings
  end

  post '/api/pressure_readings' do
    return unauthorized unless valid_token? request

    PressureReading.create(**request.params)
    201
  end

  delete '/api/pressure_readings/:id' do |id|
    return unauthorized unless valid_token? request

    PressureReading[id]&.delete
    200
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
