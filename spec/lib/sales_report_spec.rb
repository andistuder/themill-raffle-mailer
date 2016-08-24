require 'spec_helper'
require 'csv'
require 'sales_report'
require 'tempfile'

RSpec.describe SalesReport do
  subject(:sales_report) { described_class.new(source: source_loc, destination: destination_file.path) }
  describe '#email_buyers' do
    let(:source_loc) { File.expand_path('../../fixtures/PayPalDownload-151008-151016-01.csv', __FILE__) }
    let(:destination_file) { Tempfile.new('destination_sales_report') }
    let(:destination_fixture) { File.expand_path('../../fixtures/augemented_report.csv', __FILE__) }
    let(:raffle_mailer) do
      double(:raffle_mailer, send_raffle_confirmation: {
               status: 202, mailed_at: 'Tue, 02 Aug 2016 19:00:42 GMT'
             })
    end

    around do |example|
      begin
        destination_file
        example.run
      ensure
        destination_file.close
        destination_file.unlink
      end
    end

    before do
      allow(ENV).to receive(:fetch).with('SENDGRID_API_KEY').and_return('dummy_key')
      allow(RaffleMailer).to receive(:new).and_return(raffle_mailer)
    end

    it 'copies the sales report to destination' do
      expect(sales_report.email_buyers).to eq(destination_file.path)

      # FileUtils.cp destination_file.path, destination_fixture
      expect(CSV.read(destination_file.path)).to eq(CSV.read(destination_fixture))
    end

    it 'calls the mailer' do
      expect(raffle_mailer).to receive(:send_raffle_confirmation).with(
        email: 'vicky.new@example.com',
        email_vars: {
          first_name: 'Victoria Viner',
          raffle_numbers: %w(
            GREEN0001
            GREEN0002
            GREEN0003
            GREEN0004
            GREEN0005
            GREEN0006
            GREEN0007
            GREEN0008
            GREEN0009
            GREEN0010
          ),
          cc: 'vicky@example.com',
        },

      )

      expect(raffle_mailer).to receive(:send_raffle_confirmation).with(
        email: 'fiona@example.com',
        email_vars: { first_name: 'Fiona Fuller',
                      raffle_numbers: %w(GREEN0011 GREEN0012 GREEN0013 GREEN0014 GREEN0015),
                      cc: nil },

      )
      expect(raffle_mailer).to receive(:send_raffle_confirmation).with(
        email: 'stephen@example.com',
        email_vars: {
          first_name: 'Stephen Smith',
          raffle_numbers: %w(
            GREEN0016
            GREEN0017
            GREEN0018
            GREEN0019
            GREEN0020
            GREEN0021
            GREEN0022
            GREEN0023
            GREEN0024
            GREEN0025
          ),
          cc: nil,
        },
      )

      sales_report.email_buyers
    end
  end
end
