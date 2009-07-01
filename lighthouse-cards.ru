require 'rubygems'
require 'sinatra'

set :env,       :production
set :port,      4577
disable :run, :reload

require 'lighthouse-cards'

run Sinatra.application