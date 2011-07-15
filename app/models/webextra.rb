class Webextra < ActiveRecord::Base
  validates :title, :name  ,:presence => true
  belongs_to :story
  belongs_to :staff
    def Webextra.send_webextra

    conditions = {}
    conditions[:check_mail] = false
    webextras = Webextra.where("check_mail = :check_mail", conditions)
        conditions = {}
    conditions[:is_assignment_editor] = true
    editors = Staff.where("is_assignment_editor = :is_assignment_editor", conditions )
    subject = 'Webextra'
    webextras.each do |webextra|
      editors.each do |editor|

        UserMailer.send_webextra( subject, webextra, Staff.find(webextra.staff_id), editor.email).deliver
        webextra.update_attribute('check_mail', true)
      end
    end
  end
end
