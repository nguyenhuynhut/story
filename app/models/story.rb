class Story < ActiveRecord::Base
  acts_as_taggable
  validates :name ,:outline ,:graphics_collateral ,:presence => true
  validates_uniqueness_of :name
  validates_length_of :name, :script, :maximum => 255
  belongs_to :producer ,:class_name => "Staff"
  belongs_to :correspondent ,:class_name => "Staff"
  belongs_to :editor ,:class_name => "Staff"
  belongs_to :staff
  has_many :airdates
  has_many :webextras
  has_many :shoots
  has_many :characters
  def Story.send_pitch
    conditions = {}
    conditions[:check_mail] = false
    conditions[:approved] = false
    pitches = Story.where("check_mail = :check_mail AND approved = :approved", conditions).find(:all)
        conditions = {}
    conditions[:is_senior_producer] = true
    seniors = Staff.where("is_senior_producer = :is_senior_producer", conditions)
    subject = 'Pitch'
    pitches.each do |pitch|
      seniors.each do |senior|

        UserMailer.send_pitch( subject, pitch, Staff.find(pitch.staff_id), senior.email).deliver
        pitch.update_attribute('check_mail', true)
      end
    end
  end
end

