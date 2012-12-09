require 'sinatra'
require './Scraper.rb'

get '/' do
  erb :index
end

get '/nikon' do
  #url = 'http://www.dwidigitalcameras.com.au/astore/Nikon-Lenses.aspx'
  url = 'offline/Nikon-Lenses.aspx'
  Scraper.new(url).to_json
end

get '/canon' do
  #url = 'http://www.dwidigitalcameras.com.au/astore/Canon-Lenses.aspx'
  url = 'offline/Canon-Lenses.aspx'
  Scraper.new(url).to_json
end

get '/sigma' do
  #url = 'http://www.dwidigitalcameras.com.au/astore/Sigma-Lenses.aspx'
  url = 'offline/Sigma-Lenses.aspx'
  Scraper.new(url).to_json
end

get '/tamron' do
  #url = 'http://www.dwidigitalcameras.com.au/astore/Tamron-Lenses.aspx'
  url = 'offline/Tamron-Lenses.aspx'
  Scraper.new(url).to_json
end

get '/tokina' do
  #url = 'http://www.dwidigitalcameras.com.au/astore/Tokina-Lenses.aspx'
  url = 'offline/Tokina-Lenses.aspx'
  Scraper.new(url).to_json
end
