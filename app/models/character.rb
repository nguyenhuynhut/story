
require 'acts-as-taggable-on'
class Character < ActiveRecord::Base
  validates :salutation  ,:first_name ,:last_name ,:address ,:state ,:city ,:zip , :presence => true
  validates_format_of :email_1 ,:email_2 ,:rep_email , :allow_nil => true, :allow_blank => true, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "must be valid"
  cattr_reader :per_page
  acts_as_taggable
  belongs_to :story
  @@per_page = 10
  def save_avatar(fileio)
    # ENSURE WE HAVE A FILE AND IT IS THE CORRECT CONTENT TYPE
    if (fileio && fileio.content_type =~ /^image/) then


      extension = File.extname(fileio.original_filename)


      file_name = self.id.to_s + '_ch_' + Time.now.to_i.to_s
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
