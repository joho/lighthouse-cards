class OpenTicketStats
  def initialize(project)
    open_ticket_count = project.open_tickets_count
    # paginate through and collect all open tickets from lighthouse
    num_pages = (open_ticket_count / 30).to_i + (open_ticket_count % 30 == 0 ? 0 : 1)
    @open_tickets = (1..num_pages).inject([]) {|tickets, page_num| tickets + project.tickets(:q => 'state:open', :page => page_num)}
  end
  
  def number_of_open_tickets
    @open_tickets.size
  end
  
  def youngest_ticket_age_in_days
    all_ticket_ages_in_days.min
  end
  
  def oldest_ticket_age_in_days
    all_ticket_ages_in_days.max
  end
  
  def average_ticket_age_in_days
    (all_ticket_ages_in_days.inject(0.0) { |sum, el| sum + el } / all_ticket_ages_in_days.size).to_i
  end
  
  def num_tickets_by_age_in_weeks
    (1..all_ticket_ages_in_weeks.max).collect do |unique_age|
      all_ticket_ages_in_weeks.select {|age| unique_age == age }.size
    end
  end
  
private
  def all_ticket_ages_in_days
    @open_tickets.collect { |t| ((Time.now - t.created_at) / 60 / 60 / 24).to_i }.sort
  end
  
  def all_ticket_ages_in_weeks
    all_ticket_ages_in_days.map { |age_in_days| age_in_days / 7 }
  end
end