require 'rubygems'
require 'haml'
require 'sinatra'
require 'hpricot'
require 'open-uri'
require 'enumerator'

use Rack::Session::Cookie, :key => 'rack.session',
                           :expire_after => 60 * 60 * 24 * 365 # a year

class Ticket
  attr_reader :id, :title, :tags
  
  def initialize(id, title, tags)
    @id, @title, @tags = id, title, tags
  end
  
  def self.ticket_doc(options = {}, page_num = 1)
    project_key = options[:project_key]
    account_name = options[:account_name]
    token = options[:auth_key]
    query = options[:query] || 'state:open'

    url = "http://#{account_name}.lighthouseapp.com/projects/#{project_key}/tickets.xml?q=#{query}&_token=#{token}&page=#{page_num}"
    Hpricot(open(url))
  end
  
  def self.all(options = {}, current_page = 1)
    
    doc = (ticket_doc(options, current_page)/'ticket')
    
    if doc.empty?
      return []
    else
      doc.collect do |ticket|
        Ticket.new((ticket/'number').inner_text, (ticket/'title').inner_text, (ticket/'tag').inner_text)
      end + all(options, current_page + 1)
    end
  end

end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  @show_config = !session[:auth_key] || params[:show_config]
  haml :index
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
  
  haml :cards
end
