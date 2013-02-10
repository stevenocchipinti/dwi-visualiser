require 'sinatra'
require './lib/DwiScraper'

get '/' do
  erb :index
end

get '/lenses/:brand' do |brand|
  if production?
    url = "http://www.dwidigitalcameras.com.au/astore/#{brand.capitalize!}-Lenses.aspx"
  else
    url = "offline/#{brand.capitalize!}-Lenses.aspx"
  end
  DwiScraper.new(url).to_json
end
