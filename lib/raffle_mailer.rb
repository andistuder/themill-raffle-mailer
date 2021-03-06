require 'sendgrid-ruby'
require_relative 'raffle_email.rb'

class RaffleMailer
  include SendGrid
  FROM_EMAIL = 'friends@themill-coppermill.org'.freeze
  FROM_NAME = 'The Mill E17'.freeze

  def initialize(api_key = ENV.fetch('SENDGRID_API_KEY'))
    @send_grid = SendGrid::API.new(api_key: api_key)
  end

  def send_raffle_confirmation(email:, email_vars: {})
    raffle_mail = RaffleEmail.new(email_vars)

    mail = Mail.new
    mail.from = Email.new(email: FROM_EMAIL, name: FROM_NAME)
    mail.subject = raffle_mail.subject_line
    mail.personalizations = personalization(email, email_vars[:cc])
    mail.contents = Content.new(type: 'text/plain', value: raffle_mail.body)

    return { status: 100, mailed_at: 'mailer disabled by user' } if ENV['DISABLE_MAILER'] == 'true'
    response = send_grid.client.mail._('send').post(request_body: mail.to_json)
    { status: response.status_code, mailed_at: response.headers['date']&.first }
  rescue StandardError => e
    puts "Error: #{e.class} #{e.message}"
    { status: 500, mailed_at: nil }
  end

  private

  attr_reader :send_grid

  def personalization(to, cc)
    personalization = Personalization.new
    personalization.to = Email.new(email: to)
    personalization.cc = Email.new(email: cc) if cc
    personalization
  end
end
