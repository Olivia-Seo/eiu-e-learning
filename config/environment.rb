# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

# ActionMailer::Base.smtp_settings = {
#   :address => 'smtp.sendgrid.net', 
#   :port => '587', 
#   :authentication => :plain, 
#   :user_name => ENV['SENDGRID_USERNAME'], 
#   :password => ENV['SENDGRID_PASSWORD'], 
#   :domain => 'heroku.com', 
#   :enable_starttls_auto => true 
# }

ActionMailer::Base.smtp_settings = {
  :user_name => 'apikey', # This is the string literal 'apikey', NOT the ID of your API key
  :password => '<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>', # This is the secret sendgrid API key which was issued during API key creation
  :domain => 'eiu-e-learning.herokuapp.com',
  :address => 'smtp.sendgrid.net',
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}