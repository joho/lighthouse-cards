class ResolvedTicketStats
  def initialize(project)
    # load all resolved tickets from the past 10 weeks
    @resolved_tickets = []
    page_num = 1
    tickets_retrieved = nil
    while(page_num == 1 || tickets_retrieved.size == 30) do
      tickets_retrieved = project.tickets(:q => "state:resolved updated:'10 weeks ago'", :page => page_num)
      @resolved_tickets += tickets_retrieved
      page_num += 1
    end
  end
  
  def total_resolved_over_ten_weeks
    @resolved_tickets.size
  end
  
  def total_resolved_last_fortnight
    tickets_resolved_last_fortnight.size
  end
  
  def average_completion_rate_over_ten_weeks
    average_completion_time_for_tickets(@resolved_tickets).to_i
  end
  
  def average_completion_rate_last_fortnight
    average_completion_time_for_tickets(tickets_resolved_last_fortnight).to_i
  end
  
  def total_tickets_resolved_by_fortnight
    tickets_grouped_by_fortnight.collect do |fortnight_num, tickets|
      tickets.size
    end.reverse
  end
  
  def average_completion_rate_by_fortnight
    tickets_grouped_by_fortnight.collect do |fortnight_num, tickets|
      average_completion_time_for_tickets(tickets)
    end.reverse
  end
  
private
  def tickets_grouped_by_fortnight
    @resolved_tickets.group_by do |ticket|
      ((10.weeks.ago - ticket.updated_at) / 60 / 60 / 24 / 14).to_i + 1
    end
  end
  
  def tickets_resolved_last_fortnight
    @resolved_tickets.select { |ticket| ticket.updated_at >= 2.weeks.ago }
  end
  
  def average_completion_time_for_tickets(tickets)
    tickets.inject(0.0) do |sum, ticket|
      sum + ((ticket.updated_at - ticket.created_at) / 60 / 60 / 24)
    end / tickets.size
  end
  
end