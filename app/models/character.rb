class Character < ActiveRecord::Base
  validates :salutation  ,:first_name ,:last_name ,:address ,:state ,:city ,:zip , :presence => true
  validates_format_of :email_1 ,:email_2 , :allow_nil => true, :allow_blank => true, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "must be valid"
  cattr_reader :per_page
  @@per_page = 10

end
