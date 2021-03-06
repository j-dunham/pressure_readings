# frozen_string_literal: true

require 'sequel'
require 'dotenv'

Dotenv.load

DB = Sequel.connect(ENV['DATABASE_URL'])

DB.create_table? :users do
  primary_key :id
  column :username, String, unique: true
  column :password, String
  column :created_at, 'timestamp with time zone', default: Sequel.function(:now)
end

DB.create_table? :pressure_readings do
  primary_key :id
  foreign_key :user_id, :users, null: false
  column :systolic, Integer
  column :diastolic, Integer
  column :created_at, 'timestamp with time zone', default: Sequel.function(:now)
end

class User < Sequel::Model
  one_to_many :pressure_readings
end

class PressureReading < Sequel::Model
  many_to_one :user
end
