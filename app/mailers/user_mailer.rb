class UserMailer < ActionMailer::Base
  default :from => "benbo.nguyen@gmail.com"

  def forgot(recipient, subject, staff, sent_at = Time.now)
    @staff = staff
    mail(:to => recipient, :subject => subject)
  end
  def contact_us(recipient, subject, staff, message,sent_at = Time.now)
    @staff = staff
    @message = message
    mail(:to => recipient, :subject => subject)
  end
  def contact_staff(recipient, subject, staff, message,sent_at = Time.now)
    @staff = staff
    @message = message
    mail(:to => recipient, :subject => subject)
  end
end
