require 'rubygems'
require 'sinatra'
require 'hpricot'
require 'open-uri'

class Ticket
  attr_reader :id, :title
  
  def initialize(id, title)
    @id, @title = id, title
  end
  
  def self.config
    @@config ||= File.open('config.yml', 'r') {|f| YAML.load(f.read) }
  end
  
  def self.ticket_doc(page_num = 1)
    project_key, account_name, token = config['project_key'], config['account_name'], config['auth_token']
    url = "http://#{account_name}.lighthouseapp.com/projects/#{project_key}/tickets.xml?q=state:open&_token=#{token}&page=#{page_num}"

    Hpricot(open(url))
  end
  
  def self.all(current_page = 1)
    doc = (ticket_doc(current_page)/'ticket')
    
    if doc.empty?
      return []
    else
      doc.collect do |ticket|
        Ticket.new((ticket/'number').inner_text, (ticket/'title').inner_text)
      end + all(current_page + 1)
    end
  end

end

get '/' do
  @tickets = Ticket.all
  haml :index
end