#!/usr/bin/env ruby
require 'drb/drb'

class TimeService

  def get_current_time
  	result = Time.now
  	puts "get_current_time: #{result}"
    return result
  end

  def do_something_else
  	return "Hello"
  end

end

$SAFE = 1   # disable eval() and friends

uri = "druby://0.0.0.0:8787"
service = TimeService.new

puts "Starting..."
DRb.start_service(uri, service)
puts "Started!"

DRb.thread.join