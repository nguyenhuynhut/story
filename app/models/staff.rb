require 'mini_magick'
class Staff < ActiveRecord::Base
  validates :userid ,:email ,:first_name ,:last_name ,:title ,:phone ,:presence => true
  validates_uniqueness_of :email
  validates_uniqueness_of :userid
  validates_length_of :userid, :minimum => 5
  validates_length_of :password, :within => 5..50
  validates_confirmation_of :password
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "must be valid"
  before_save :hash_password
  has_many :shoots ,:dependent => :destroy
  has_many :stories ,:dependent => :destroy
  has_many :stories , :dependent => :destroy
  has_many :webextra , :dependent => :destroy
  def hash_password
    if password_changed?
      self.password = Digest::SHA1.hexdigest(password)
    end
  end
  def save_avatar(fileio)
    # ENSURE WE HAVE A FILE AND IT IS THE CORRECT CONTENT TYPE
    if (fileio && fileio.content_type =~ /^image/) then


      extension = File.extname(fileio.original_filename)


      file_name = self.id.to_s + '_' + Time.now.to_i.to_s
            AWS::S3::S3Object.store(sanitize_filename(file_name + extension), fileio.read, BUCKET, :access => :public_read)

  
      # PERFORM THE MINIMAGICK CHANGES

      begin
        mm = MiniMagick::Image.open(AWS::S3::S3Object.url_for(file_name + extension, BUCKET, :authenticated => false), File.extname(AWS::S3::S3Object.url_for(file_name + extension, BUCKET, :authenticated => false)))

        mm.resize("60X60")
        mm.write(AWS::S3::S3Object.url_for(file_name + extension, BUCKET, :authenticated => false))
      rescue
      end
      # UPDATE ATTRIBUTES
      self.avatar = AWS::S3::S3Object.url_for(file_name + extension, BUCKET, :authenticated => false)
      self.update_attribute("avatar", AWS::S3::S3Object.url_for(file_name + extension, BUCKET, :authenticated => false))
    end
  end

  def sanitize_filename(file_name)
    just_filename = File.basename(file_name)
    just_filename.sub(/[^\w\.\-]/,'_')
  end
end
