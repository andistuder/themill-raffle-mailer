require 'csv'
require_relative 'raffle_mailer'

class SalesReport
  def initialize(source:, destination:)
    raise ArgumentError, "File not found: #{source}" unless File.exist?(source)
    @source_file = File.open(source, 'r')
    @destination_file = File.open(destination, 'w')
  end

  def email_buyers
    destination_csv = CSV.new(destination_file)
    CSV.new(source_file, headers: true).each_with_index do |sales_record, i|
      destination_csv << sales_record.headers + %w(email_status emailed_at) if i == 0
      destination_csv << if sales_record[' Item ID'] == 'Raffle'
                           sales_record.to_h.values + email_buyer(sales_record).values
                         else
                           sales_record
                         end
    end
    destination_file.path
  ensure
    destination_file.close
    source_file.close
  end

  private

  attr_reader :source_file, :destination_file

  def email_buyer(sales_record)
    raffle_mailer.send_raffle_confirmation(
      email: sales_record[' From Email Address'],
      email_vars: {
        first_name: sales_record[' Name'],
        raffle_numbers: [],
      },
    )
  end

  def raffle_mailer
    @raffle_mailer ||= RaffleMailer.new(api_key: ENV.fetch('SENDGRID_API_KEY'))
  end
end
