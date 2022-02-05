# frozen_string_literal: true

require 'sequel'
require 'dotenv'

Dotenv.load

DB = Sequel.connect(ENV['DATABASE_URL'])

DB.create_table? :links do
  column :id, Integer, primary_key: true
  column :name, String, unique: true, null: false
  column :url, String
  column :description, String
  column :created_at, DateTime, default: Sequel.function(:now)
end

DB.create_table? :books do
  column :id, Integer, primary_key: true
  column :name, String, unique: true, null: false
  column :author, String
  column :url, String
  column :description, String
end

class Links < Sequel::Model
end

class Books < Sequel::Model
end
