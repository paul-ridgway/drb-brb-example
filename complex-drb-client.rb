#!/usr/bin/env ruby
require 'drb/drb'

# The URI to connect to
uri = "druby://localhost:8787"
DRb.start_service
service = DRbObject.new_with_uri(uri)

puts "Time: #{service.get_current_time}"

calculator = service.get_calculator
puts "add(3, 7): #{calculator.add(3, 7)}"

puts "name: #{calculator.name}"