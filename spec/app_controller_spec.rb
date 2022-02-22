# frozen_string_literal: true

ENV['DATABASE_URL'] = 'sqlite://test.db'

require 'rspec'
require 'rack/test'
require 'sequel'
require_relative '../app/controllers/app_controller'

describe 'app controller' do
  include Rack::Test::Methods

  def app
    AppController
  end

  describe 'when handling a get to /' do
    it 'returns successful' do
      get '/'
      expect(last_response).to be_ok
    end
  end

  describe 'when handling a request for a unknown route' do
    it 'returns a 404' do
      get '/unknown'
      expect(last_response.status).to eq(404)
    end
  end
end
