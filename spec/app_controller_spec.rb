# frozen_string_literal: true

ENV['DATABASE_URL'] = 'sqlite://test.db'

require 'rspec'
require 'rack/test'
require 'sequel'
require_relative '../app/controllers/app_controller'

describe 'the server' do
  include Rack::Test::Methods

  def app
    AppController
  end

  describe 'when calling /' do
    it 'returns successful' do
      get '/'
      expect(last_response).to be_ok
    end
  end
end
