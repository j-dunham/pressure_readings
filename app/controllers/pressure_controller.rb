# frozen_string_literal: true

require 'rack'
require 'sinatra/base'
require 'sinatra/reloader'
require 'sequel'
require 'twilio-ruby'
require 'bcrypt'

require_relative '../db/models'

class PressureController < AppController
  use Rack::TwilioWebhookAuthentication, ENV['TWILIO_AUTH_TOKEN'], '/twilio'

  get '/pressure_reading' do
    redirect '/' unless current_user

    @readings = PressureReading.all

    erb :readings
  end

  post '/api/pressure_reading' do
    return unauthorized unless valid_token? request

    PressureReading.create(**request.params)
    201
  end

  delete '/api/pressure_reading/:id' do |id|
    return unauthorized unless valid_token? request

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
end
