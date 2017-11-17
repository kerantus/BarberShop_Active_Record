#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

#=================================================

set :database, "sqlite3:barbershop.db"

class Client < ActiveRecord::Base
end

class Barbers < ActiveRecord::Base
end

#==================================================



get '/' do
  @barbers = Barbers.order "created_at DESC"
	erb :index
end

get '/visit' do
	@master = Barbers.all
  erb :visit
end