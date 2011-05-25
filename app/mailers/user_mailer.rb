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
  def send_pitch(subject, pitch, staff, email ,sent_at = Time.now)
    @pitch = pitch
    @staff = staff
    mail(:to => email, :subject => subject)
  end
  def send_shoot(subject, shoot, approver, email ,sent_at = Time.now)
    @shoot = shoot
    @staff = approver
    mail(:to => email, :subject => subject)
  end
  def send_webextra(subject, webextra, staff, email ,sent_at = Time.now)
    @webextra = webextra
    @staff = staff
    mail(:to => email, :subject => subject)
  end
end
