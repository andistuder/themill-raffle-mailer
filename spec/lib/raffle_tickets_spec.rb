require 'spec_helper'
require 'raffle_tickets'

RSpec.describe RaffleTickets do
  let(:store_location) { File.expand_path('../../fixtures/raffle_tickets.yaml', __FILE__) }
  subject(:load_raffle_tickets) { described_class.load(store_location: store_location) }
  let(:expected_tickets) { %w(XY1 XY2 XY3 XY4 XY5 XY6 XY7 AC2 AC3 AC4 AC5 AC6 AC7 AC8) }
  describe '.load' do
    it 'returns an raffle tickets object' do
      expect(load_raffle_tickets).to be_a(RaffleTickets)
    end

    it 'loads tickets from file' do
      expect(load_raffle_tickets.send(:tickets)).to eq(expected_tickets)
    end
  end
  describe '#shift' do
    let!(:raffle_ticket) { load_raffle_tickets }

    it 'returns tickets as requested' do
      expect(raffle_ticket.shift(2)).to eq(%w(XY1 XY2))
      expect(raffle_ticket.shift(2)).to eq(%w(XY3 XY4))
    end

    context 'when running out of tickets' do
      it 'returns an error' do
        expect { raffle_ticket.shift(expected_tickets.size + 1) }.to raise_error(ArgumentError)
      end
    end
  end
end
