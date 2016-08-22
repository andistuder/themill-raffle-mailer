require 'spec_helper'
require 'raffle_tickets'

RSpec.describe RaffleTickets do
  let(:store_location) { File.expand_path('../../fixtures/raffle_tickets.yaml', __FILE__) }
  subject(:load_raffle_tickets) { described_class.load(store_location: store_location) }
  let(:expected_tickets) do
    %w(XY0001 XY0002 XY0003 XY0004 XY0005 XY0006 XY0007 AC0002 AC0003 AC0004 AC0005 AC0006 AC0007 AC0008)
  end
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
      expect(raffle_ticket.shift(2)).to eq(%w(XY0001 XY0002))
      expect(raffle_ticket.shift(2)).to eq(%w(XY0003 XY0004))
    end

    context 'when running out of tickets' do
      it 'returns an error' do
        expect { raffle_ticket.shift(expected_tickets.size + 1) }.to raise_error(ArgumentError)
      end
    end
  end
end
