# Load the rails application
require File.expand_path('../application', __FILE__)
require 'mini_magick'
# Initialize the rails application
StorySystem::Application.initialize!
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.content_type = "text/html"
mails

ENV['RECAPTCHA_PUBLIC_KEY'] = '6LenbsISAAAAAIIHxs6lrS-BmvysURpDqijUVzpJ'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LenbsISAAAAALv1X8BUCuHM_tGzREGAfOr36zTf '