require 'yaml'
class RaffleTickets
  DEFAULT_STORE_LOCATION = File.expand_path('../../data/raffle_tickets.yaml', __FILE__)

  def self.load(store_location: ENV.fetch('TICKET_STORE_LOCATION', DEFAULT_STORE_LOCATION))
    tickets = YAML.load(File.read(store_location)).map do |series|
      Range.new(series['from'].to_i, series['to'].to_i).map { |i| series['prefix'] + i.to_s.rjust(4, '0') }
    end.flatten
    new(tickets)
  end

  def initialize(tickets)
    @tickets = tickets
  end

  def shift(n)
    # rubocop:disable Metrics/LineLength
    raise ArgumentError, "Not enough tickets available, requested: #{n}, available: #{tickets.size}, first of remaining tickets: #{tickets.first}" if n > tickets.size
    # rubocop:enable Metrics/LineLength
    tickets.shift(n)
  end

  def close
    puts "First of remaining tickets: #{tickets.first}"
  end

  private

  attr_reader :tickets
end
