# class ApplicationMailer < ActionMailer::Base
#   default from: 'support@eiu-e-learning.herokuapp.com'
#   layout 'mailer'
# end

class UserNotifierMailer < ApplicationMailer
  default :from => 'support@eiu-e-learning.herokuapp.com'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_signup_email(user)
    @user = user
    mail( :to => @user.email,
    :subject => 'Thanks for signing up for our amazing app' )
  end
end
