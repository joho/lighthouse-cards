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
    Hpricot.XML(open(url))
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