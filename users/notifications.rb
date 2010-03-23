class Notifications < ActionMailer::Base
  def password_reset_instructions(user)
    subject       "Password Reset"
    from          sender_email
    recipients    [user.email]
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def user_approved(user)
    subject     "Access Approved"
    from        sender_email
    recipients  [user.email]
    body        :user => user, :first_login_link => edit_password_reset_url(user.perishable_token)
  end

  private

  def sender_email
    "Application Admin <admin@website.url>"
  end
end
