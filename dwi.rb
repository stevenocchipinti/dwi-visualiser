require 'sinatra'
require './LensBrand.rb'

get '/' do
  #url = 'http://www.dwidigitalcameras.com.au/astore/Sigma-Lenses.aspx'
  url = 'offline/Sigma-Lenses.aspx'
  lenses = LensBrand.new(url)
  erb :index, :locals => { :lenses_json => lenses.to_json }
end
