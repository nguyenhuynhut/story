class Webextra < ActiveRecord::Base
  validates :title  ,:presence => true
  belongs_to :stories
  belongs_to :staff
    def Webextra.send_webextra
    webextras = Webextra.where(:check => false )
    editors = Staff.where(:is_assignment_editor => true )
    subject = 'Webextra'
    webextras.each do |webextra|
      editors.each do |editor|

        UserMailer.send_webextra( subject, webextra, Staff.find(webextra.staff_id), editor.email).deliver
        webextra.update_attribute('check', true)
      end
    end
  end
end
