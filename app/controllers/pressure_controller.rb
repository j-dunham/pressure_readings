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

    @readings = PressureReading.where(user_id: current_user_id).all.reverse

    erb :list_readings
  end

  get '/add_reading' do
    redirect '/' unless current_username

    erb :add_reading
  end

  get '/reading_summary' do
    redirect '/' unless current_username
    days_before_today = params['days'].to_i

    dataset = DB[:pressure_readings].where(user_id: 4).where { created_at > (Date.today - days_before_today) }
    @count = dataset.count
    @systolic_max = dataset.max(:systolic)
    @diastolic_max = dataset.max(:diastolic)
    @systolic_average = dataset.sum(:systolic) / @count
    @diastolic_average = dataset.sum(:diastolic) / @count

    erb :read_summary, locals: { days: days_before_today }
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
