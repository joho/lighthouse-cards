require 'sinatra'

set :env,       :production
require 'lighthouse-cards'
run Sinatra::Application