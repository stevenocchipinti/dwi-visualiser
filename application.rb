require 'sinatra'
require './Scraper.rb'

get '/' do
  erb :index
end

get '/lenses/:brand' do |brand|
  if ENV['SINATRA_ENV'] == 'production'
    url = "http://www.dwidigitalcameras.com.au/astore/#{brand.capitalize!}-Lenses.aspx"
  else
    url = "offline/#{brand.capitalize!}-Lenses.aspx"
  end
  Scraper.new(url).to_json
end
