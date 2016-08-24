require 'spec_helper'
require 'raffle_mailer'
require 'sendgrid-ruby'

RSpec.describe RaffleMailer do
  describe '.send_raffle_confirmation' do
    subject(:send_raffle_confirmation) do
      described_class.new(api_key).send_raffle_confirmation(email: recipient, email_vars: email_vars)
    end
    let(:email_vars) { { cc: nil } }
    let(:send_grid) { double(:send_grid, client: double(:client, mail: mail)) }
    let(:raffle_email) { double(:raffle_email, subject_line: 'Hello World', body: 'Hello, Email!') }
    let(:mail) { double(:mail, _: mail_helper) }
    let(:mail_helper) { double(:mail_helper, post: response) }
    let(:response) { double(:response, status_code: 202, body: 'response body', headers: response_headers) }
    let(:response_headers) do
      {
        'server' => ['nginx'],
        'date' => ['Tue, 02 Aug 2016 19:00:42 GMT'],
        'content-type' => ['text/plain; charset=utf-8'],
        'content-length' => ['0'],
        'connection' => ['close'],
        'x-message-id' => ['w1CCw2fPQ7ibGd1_Dq_UmA'],
        'x-frame-options' => ['DENY'],
      }
    end
    let(:post_body) do
      {
        request_body: {
          'from' => { 'email' => 'friends@themill-coppermill.org', 'name' => 'The Mill E17' },
          'subject' => 'Hello World',
          'personalizations' => [{ 'to' => [{ 'email' => 'raffle_player@example.com' }] }],
          'content' => [{ 'type' => 'text/plain', 'value' => 'Hello, Email!' }],
        },
      }
    end
    let(:api_key) { '1234abcd' }
    let(:recipient) { 'raffle_player@example.com' }

    before do
      allow(SendGrid::API).to receive(:new).with(api_key: api_key).and_return(send_grid)
      allow(RaffleEmail).to receive(:new).and_return(raffle_email)
    end

    it 'returns a receipt with mailed_at time' do
      expect(mail).to receive(:_).with('send')
      expect(send_raffle_confirmation).to eq(status: 202, mailed_at: 'Tue, 02 Aug 2016 19:00:42 GMT')
    end

    it 'posts the correct body' do
      expect(mail_helper).to receive(:post).with(post_body)
      send_raffle_confirmation
    end

    it 'passes the email_vars to the raffle_mailer' do
      expect(RaffleEmail).to receive(:new).with(email_vars)
      send_raffle_confirmation
    end

    context 'when the mail client raises an error' do
      it 'returns a receipt with status 500' do
        allow(mail_helper).to receive(:post).and_raise(RuntimeError, 'Meh, something went wrong')
        expect(send_raffle_confirmation).to eq(status: 500, mailed_at: nil)
      end
    end
    context 'when the mailer is disbaled' do
      before do
        stub_const('ENV', ENV.to_hash.merge('DISABLE_MAILER' => 'true'))
      end
      it 'return code 100' do
        expect(send_raffle_confirmation).to eq(status: 100, mailed_at: 'mailer disabled by user')
      end
    end
  end
end
