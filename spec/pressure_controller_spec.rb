# frozen_string_literal: true

ENV['DATABASE_URL'] = 'sqlite://test.db'
ENV['APP_ENV'] = 'testing'

require 'rspec'
require 'rack/test'
require 'sequel'
require_relative '../app/controllers/pressure_controller'
require_relative '../app/db/models'

describe 'pressure controller' do
  include Rack::Test::Methods

  def app
    PressureController
  end

  describe 'when handling a get request to list_reading' do
    context 'and user not logged in' do
      it 'returns redirects to index page' do
        get '/list_readings'
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.url).to eq('http://example.org/')
      end
    end
    context 'and user logged in' do
      it 'returns successful' do
        env 'rack.session', { username: 'matz', user_id: 1 }
        get '/list_readings'
        expect(last_response).to be_ok
        expect(last_response.body).to include('<h1>Readings</h1>')
      end
    end
  end

  describe 'when handling a get request to add_reading' do
    context 'and not logged in' do
      it 'returns redirects to index page' do
        get '/add_reading'
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.url).to eq('http://example.org/')
      end
    end
    context 'and user logged in' do
      it 'returns successful' do
        env 'rack.session', { username: 'matz', user_id: 1 }
        get '/add_reading'
        expect(last_response).to be_ok
        expect(last_response.body).to include('<h1>Add Reading</h1>')
      end
    end
  end

  describe 'when handling a post to pressure_reading' do
    context 'and user not logged in' do
      it 'returns redirects to index page' do
        post '/pressure_reading'
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.url).to eq('http://example.org/')
      end
    end
    context 'and user logged in' do
      before do
        DB.run('delete from pressure_readings')
        DB.run('delete from users')
        user = User.create(username: 'matz', created_at: DateTime.now)
        ENV['DEFAULT_USER_ID'] = user.id.to_s
      end

      it 'returns successful' do
        env 'rack.session', { username: 'matz', user_id: '1' }
        post '/pressure_reading', { 'systolic' => '140', 'diastolic' => '80', 'created_at' => DateTime.now }
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_response.body).to include('<h1>Readings</h1>')
      end
    end
  end
end
