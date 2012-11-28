require 'sinatra'
require './LensCollection.rb'

get '/' do
  #url = 'http://www.dwidigitalcameras.com.au/astore/Sigma-Lenses.aspx'
  url = 'offline/Sigma-Lenses.aspx'
  lenses = LensCollection.new(url)
  erb :index, :locals => { :lenses_json => lenses.to_json }
end
