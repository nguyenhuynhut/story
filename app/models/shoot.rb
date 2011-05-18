class Shoot < ActiveRecord::Base
  validates :crew_requirements  ,:location ,:notes , :presence => true
  belongs_to :cameraperson ,:class_name => 'Staff'
  belongs_to :approver ,:class_name => 'Staff'
  belongs_to :story
end
