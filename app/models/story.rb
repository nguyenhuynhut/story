class Story < ActiveRecord::Base
  validates :name ,:outline ,:graphics_collateral ,:presence => true
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
    pitches = Story.where(:check => false , :approved => false)
    seniors = Staff.where(:is_senior_producer => true )
    subject = 'Pitch'
    pitches.each do |pitch|
      seniors.each do |senior|

        UserMailer.send_pitch( subject, pitch, Staff.find(pitch.staff_id), senior.email).deliver
        pitch.update_attribute('check', true)
      end
    end
  end
end
