class Shoot < ActiveRecord::Base
  validates :crew_requirements  ,:location ,:notes , :presence => true
  belongs_to :cameraperson ,:class_name => 'Staff'
  belongs_to :approver ,:class_name => 'Staff'
  belongs_to :story
    def Shoot.send_shoot
    shoots = Shoot.where(:check => false)
    conditions = {}
    conditions[:is_is_senior_producer] = true
    conditions[:is_assignment_editor] = true
    accessors = Staff.where("is_senior_producer = :is_is_senior_producer or is_assignment_editor = :is_assignment_editor", conditions)
    subject = 'Shoot'
    shoots.each do |shoot|
      accessors.each do |accessor|
        UserMailer.send_shoot( subject, shoot, shoot.approver, accessor.email).deliver
        shoot.update_attribute("check", false)
      end
    end
  end
end
