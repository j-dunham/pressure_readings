# frozen_string_literal: true

require 'sequel'
require 'dotenv'

Dotenv.load

DB = Sequel.connect(ENV['DATABASE_URL'])

DB.create_table? :pressure_readings do
  primary_key :id
  column :systolic, String
  column :diastolic, String
  column :created_at, 'timestamp with time zone', default: Sequel.function(:now)
end

class PressureReading < Sequel::Model
end
