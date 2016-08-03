require 'spec_helper'
require 'raffle_email'

RSpec.describe RaffleEmail do
  let(:first_name) { 'Nat' }
  let(:raffle_numbers) { %w(A12 A13) }
  subject(:raffle_email) { described_class.new(first_name: first_name, raffle_numbers: raffle_numbers) }

  describe '#subject_line' do
    it 'returns the subject line' do
      expect(raffle_email.subject_line).to eq('The Mill E17 Raffle Confirmation')
    end
  end

  describe '#body' do
    it 'returns the email body' do
      expected_content = File.read(File.expand_path('../../fixtures/email_body.txt', __FILE__))
      expect(raffle_email.body).to eq(expected_content)
    end
    context 'when initialized empty' do
      subject(:raffle_email) { described_class.new({}) }

      it 'returns the email body' do
        expected_content = File.read(File.expand_path('../../fixtures/email_body_empty.txt', __FILE__))
        expect(raffle_email.body).to eq(expected_content)
      end
    end
  end
end
