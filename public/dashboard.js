function setupTicketsByAgeGraph() {
  var r = Raphael("ticket-age-graph"),
      fin = function () {
          this.flag = r.g.popup(this.bar.x, this.bar.y, this.bar.value || "0").insertBefore(this);
      },
      fout = function () {
          this.flag.animate({opacity: 0}, 300, function () {this.remove();});
      },
      fin2 = function () {
          var y = [], res = [];
          for (var i = this.bars.length; i--;) {
              y.push(this.bars[i].y);
              res.push(this.bars[i].value || "0");
          }
          this.flag = r.g.popup(this.bars[0].x, Math.min.apply(Math, y), res.join(", ")).insertBefore(this);
      },
      fout2 = function () {
          this.flag.animate({opacity: 0}, 300, function () {this.remove();});
      };

  
  // set up the graph dimensions for the ticket age
  var ticket_age_graph_container = $('div#ticket-age-graph');
  var ticket_age_graph_width = ticket_age_graph_container.width();
  var ticket_age_graph_height = ticket_age_graph_container.height() - 20;
  var ticket_age_graph_x_pos = 5;
  var ticket_age_graph_y_pos = 5;
  
  // plot number of tickets up the y axis
  r.g.txtattr.font = "14px Helvetica, sans-serif";
  r.g.txtattr.color = "#B0C4DE";
  var max_ticket_age_frequency = Math.max.apply(Math, ticket_age_by_week);
  r.g.text(ticket_age_graph_width - 50, ticket_age_graph_y_pos + 10, max_ticket_age_frequency + " Tickets");
  r.rect(ticket_age_graph_x_pos, ticket_age_graph_y_pos + 15, ticket_age_graph_width - 50, 1).attr({fill: "#B0C4DE", stroke: "#B0C4DE"});
  var halfway_number_of_tickets = Math.floor(max_ticket_age_frequency / 2);
  r.rect(ticket_age_graph_x_pos, (ticket_age_graph_y_pos + 10) + (ticket_age_graph_height / 2) + 15, ticket_age_graph_width - 50, 1).attr({fill: "#B0C4DE", stroke: "#B0C4DE"});
  r.g.text(ticket_age_graph_width - 50, (ticket_age_graph_y_pos + 10) + (ticket_age_graph_height / 2), halfway_number_of_tickets + " Tickets");
  
  // set up the graph
  r.g.barchart(ticket_age_graph_x_pos, ticket_age_graph_y_pos, ticket_age_graph_width, ticket_age_graph_height, [ticket_age_by_week]).hover(fin, fout);

  // plot all the number of weeks for the legend
  var horizontal_spacing = (ticket_age_graph_width - ticket_age_graph_x_pos) / ticket_age_by_week.length;      
  r.g.txtattr.font = (horizontal_spacing / 2) + "px Helvetica, sans-serif";
  for (var i = 1; i <= ticket_age_by_week.length; i++) {
    r.g.text(ticket_age_graph_x_pos + (i * (horizontal_spacing - 1)) , ticket_age_graph_height + ticket_age_graph_y_pos, i).rotate(45, true);
  }

  // reset the font for the hovers etc
  r.g.txtattr.font = "14px Helvetica, sans-serif";
}

function setupResolvedTicketsGraph() {
  var c = Raphael('tickets-resolved-by-fortnight');
  
  var resolved_ticket_graph_container = $('div#ticket-age-graph');
  var resolved_ticket_graph_width = resolved_ticket_graph_container.width() - 50;
  var resolved_ticket_graph_height = resolved_ticket_graph_container.height() - 50;
  // ticket_resolution_by_fortnight
  // ticket_completion_rates_by_fortnight
  var lines = c.g.linechart(10, 10, resolved_ticket_graph_width, resolved_ticket_graph_height, 
                      [1, 2, 3, 4, 5],
                      [ticket_resolution_by_fortnight, ticket_completion_rates_by_fortnight],
                      {nostroke: false, axis: "0 0 1 1", symbol: "o"}).hoverColumn(function () {
                      this.tags = c.set();
                      for (var i = 0, ii = this.y.length; i < ii; i++) {
                          this.tags.push(c.g.tag(this.x, this.y[i], this.values[i], 160, 10).insertBefore(this).attr([{fill: "#fff"}, {fill: this.symbols[i].attr("fill")}]));
                      }
                  }, function () {
                      this.tags && this.tags.remove();
                  });
  
}