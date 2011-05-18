class Story < ActiveRecord::Base
  validates :name ,:outline ,:graphics_collateral ,:presence => true
  validates_length_of :name, :script, :maximum => 255
  belongs_to :producer ,:class_name => "Staff"
  belongs_to :correspondent ,:class_name => "Staff"
  belongs_to :editor ,:class_name => "Staff"
  has_many :airdates
  has_many :webextras
  has_many :shoots
  has_many :characters
end
