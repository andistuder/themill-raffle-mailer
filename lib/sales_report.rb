require 'csv'
require_relative 'raffle_mailer'
require_relative 'raffle_tickets'

class SalesReport
  def initialize(source:, destination:)
    raise ArgumentError, "File not found: #{source}" unless File.exist?(source)
    @source_file = File.open(source, 'r')
    @destination_file = File.open(destination, 'w')
  end

  def email_buyers
    destination_csv = CSV.new(destination_file)
    CSV.new(source_file, headers: true).each_with_index do |sales_record, i|
      destination_csv << sales_record.headers + %w(raffle_tickets email_status emailed_at) if i == 0
      destination_csv << process(sales_record)
    end
    destination_file.path
  ensure
    raffle_tickets.close
    destination_file.close if destination_file
    source_file.close
  end

  private

  attr_reader :source_file, :destination_file

  def process(sales_record)
    return sales_record unless sales_record[' Item ID'] == 'Raffle'
    values = sales_record.to_h.values
    tickets = issue_raffle_tickets(sales_record)
    values << tickets.join(':')
    values + email_buyer(sales_record, tickets).values
  end

  def issue_raffle_tickets(sales_record)
    raffle_tickets.shift(sales_record[' Gross'].to_i)
  end

  def email_buyer(sales_record, tickets)
    raffle_mailer.send_raffle_confirmation(
      email: sales_record[' From Email Address'],
      email_vars: {
        first_name: sales_record[' Name'],
        raffle_numbers: tickets,
      },
    )
  end

  def raffle_mailer
    @raffle_mailer ||= RaffleMailer.new
  end

  def raffle_tickets
    @raffle_tickets ||= RaffleTickets.load
  end
end
