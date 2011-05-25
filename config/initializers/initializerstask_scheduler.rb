
require 'rubygems'
require 'rufus/scheduler'

## to start scheduler
scheduler = Rufus::Scheduler.start_new

## It will print message every i minute
scheduler.every("2h") do
  puts 'Check pitch'
  puts Story.send_pitch
end
scheduler.every("3h") do
  puts 'Check shoot'
  puts Shoot.send_shoot
end
scheduler.every("4h") do
  puts 'Check webextra'
  puts Webextra.send_webextra
end