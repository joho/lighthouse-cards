require 'rubygems'
require 'haml'
require 'sinatra'
require 'hpricot'
require 'open-uri'
require 'enumerator'
require 'lighthouse-api'
require 'active_support'

use Rack::Session::Cookie, :key => 'rack.session',
                           :expire_after => 60 * 60 * 24 * 365 # a year

require 'models/ticket'
require 'models/open_ticket_stats'
require 'models/resolved_ticket_stats'

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  @show_config = !session[:auth_key] || params[:show_config]
  haml :index
end

post '/store_config_in_session' do
  [:auth_key, :account_name, :project_key].each do |config_key|
    session[config_key] = params[config_key]
  end
  redirect '/'
end

post '/print' do
  options = {}
  [:auth_key, :account_name, :project_key, :query].each do |search_option|
    options[search_option] = params[search_option] && !params[search_option].empty? ? params[search_option] : session[search_option]
    session[search_option] = options[search_option] if params[:save_config]
  end

  @tickets = Ticket.all(options)
  if params[:ticket_ids] && !params[:ticket_ids].empty?
    ticket_ids = params[:ticket_ids].split(',').collect {|id| id.to_i}
    @tickets = @tickets.select {|ticket| ticket_ids.include?(ticket.id.to_i) }
  elsif params[:tickets_greater_than] && !params[:tickets_greater_than].empty?
    ticket_id = params[:tickets_greater_than].to_i
    @tickets = @tickets.select {|ticket| ticket.id.to_i >= ticket_id }
  end
  
  haml :cards, :layout => false
end

get '/dashboard' do
  Lighthouse.account = session[:account_name]
  Lighthouse.token = session[:auth_key]
  
  project = Lighthouse::Project.find(session[:project_key])


  @open_ticket_stats = OpenTicketStats.new(project)
  
  @resolved_ticket_stats = ResolvedTicketStats.new(project)
  
  haml :dashboard
end
