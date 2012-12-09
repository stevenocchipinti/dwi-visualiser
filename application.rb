require 'sinatra'
require './Scraper.rb'

get '/' do
  erb :index
end

get '/:brand' do |brand|
  #url = 'http://www.dwidigitalcameras.com.au/astore/Nikon-Lenses.aspx'
  url = "offline/#{brand.capitalize!}-Lenses.aspx"
  Scraper.new(url).to_json
end
