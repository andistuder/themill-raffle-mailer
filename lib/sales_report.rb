class SalesReport
  def initialize(source_report)
    raise ArgumentError, "File not found: #{report_location}" unless File.exist?(source_report)
    @source_report = source_report
  end

  def process
    # allocate raffle tickets
    # require 'erb'
  end

  private

  attr_reader @source_report
end
