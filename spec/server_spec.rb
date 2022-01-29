# frozen_string_literal: true

ENV['DATABASE_URL'] = 'sqlite://test.db'

require 'rspec'
require 'rack/test'
require_relative '../app/server'

describe 'the server' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe 'when calling /' do
    it 'returns successful' do
      get '/'
      expect(last_response).to be_ok
    end
  end
end
