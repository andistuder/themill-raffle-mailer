require 'sendgrid-ruby'

class RaffleMailer
  include SendGrid
  FROM_EMAIL = 'friends@themill-coppermill.org'.freeze

  def initialize(api_key)
    @send_grid = SendGrid::API.new(api_key: api_key)
  end

  def send_raffle_confirmation(to:)
    from = Email.new(email: FROM_EMAIL)
    subject = 'Hello World from the SendGrid Ruby Library!'
    to = Email.new(email: to)
    content = Content.new(type: 'text/plain', value: 'Hello, Email!')
    mail = Mail.new(from, subject, to, content)

    response = send_grid.client.mail._('send').post(request_body: mail.to_json)
    { status: response.status_code, mailed_at: response.headers['date']&.first }
  end

  private

  attr_reader :send_grid
end
