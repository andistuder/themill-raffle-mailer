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
  end
end
