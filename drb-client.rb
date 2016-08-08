#!/usr/bin/env ruby
require 'drb/drb'

# The URI to connect to
uri = "druby://localhost:8787"

timeserver = DRbObject.new_with_uri(uri)
puts "Time: #{timeserver.get_current_time}"
puts "Something Else: #{timeserver.do_something_else}"