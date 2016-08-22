require 'erb'

class RaffleEmail
  def initialize(email_vars = {})
    @draw_date_string = '1st October 2016'
    @signatory = 'Andi Studer'
    @first_name = email_vars[:first_name] || 'friend'
    @raffle_numbers = email_vars[:raffle_numbers] || []
  end

  def subject_line
    'The Mill E17 Raffle Confirmation'
  end

  def body
    mail_template = File.read(File.expand_path('../../mail_templates/default.txt.erb', __FILE__))
    ERB.new(mail_template).result(binding)
  end

  private

  attr_reader :first_name, :draw_date_string, :signatory, :raffle_numbers
end
