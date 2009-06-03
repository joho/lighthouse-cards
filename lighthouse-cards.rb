require 'rubygems'
require 'sinatra'
require 'hpricot'
require 'open-uri'
require 'enumerator'

class Ticket
  attr_reader :id, :title, :tags
  
  def initialize(id, title, tags)
    @id, @title, @tags = id, title, tags
  end
  
  def mark_printed!
    project_key, account_name, token = Ticket.config['project_key'], Ticket.config['account_name'], Ticket.config['auth_token']

    new_tags = "card-printed " + @tags.to_s

    uri = URI.parse("http://#{account_name}.lighthouseapp.com/projects/#{project_key}/tickets/#{id}.xml?_token=#{token}")
    Net::HTTP.start(uri.host, uri.port) do |http|
      headers = {'Content-Type' => 'text/plain; charset=utf-8'}
      put_data = "<ticket><tag>#{new_tags}</tag></ticket>"
      response = http.send_request('PUT', uri.request_uri, put_data,
    headers)
    
      p response
    end
    
  end
  
  def self.config
    @@config ||= File.open('config.yml', 'r') {|f| YAML.load(f.read) }
  end
  
  def self.ticket_doc(page_num = 1)
    project_key, account_name, token = config['project_key'], config['account_name'], config['auth_token']
    url = "http://#{account_name}.lighthouseapp.com/projects/#{project_key}/tickets.xml?q=state:open%20not-tagged:card-printed&_token=#{token}&page=#{page_num}"

    Hpricot(open(url))
  end
  
  def self.all(current_page = 1)
    doc = (ticket_doc(current_page)/'ticket')
    
    if doc.empty?
      return []
    else
      doc.collect do |ticket|
        Ticket.new((ticket/'number').inner_text, (ticket/'title').inner_text, (ticket/'tag').inner_text)
      end + all(current_page + 1)
    end
  end

end

get '/' do
  haml :index
end

post '/print_specific' do
  ticket_ids = params[:ticket_ids].split(',').collect {|id| id.to_i}
  @tickets = Ticket.all.select {|ticket| ticket_ids.include?(ticket.id.to_i)}
  
  haml :cards
end

post '/print_greater_than' do
  ticket_id = params[:ticket_id].to_i
  @tickets = Ticket.all.select {|ticket| ticket.id.to_i >= ticket_id }
  
  haml :cards
end

get '/print_all' do
  @tickets = Ticket.all
end

post '/mark_printed' do
  tickets = Ticket.all
  tickets.each do |ticket|
    ticket.mark_printed!
  end
  
  "blah!"
end