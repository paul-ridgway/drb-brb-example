#!/usr/bin/env ruby
require 'drb/drb'

$i = 0

class Calculator

	# Make dRuby send Logger instances as dRuby references, not copies.
    include DRb::DRbUndumped

    def initialize
    	$i += 1
    	@name = "Calc##{$i}"
		puts "[#{@name}] Calculator created"
    end

	def add(a, b)
		result = a + b
		puts "[#{@name}] Adding: #{a} + #{b} = #{result}"
		return result
	end

	def name
		@name
	end

end

class ExampleService

  def get_current_time
  	result = Time.now
  	puts "get_current_time: #{result}"
    return result
  end

  def get_calculator
  	return Calculator.new
  end

end

$SAFE = 1   # disable eval() and friends

uri = "druby://0.0.0.0:8787"
service = ExampleService.new

puts "Starting..."
DRb.start_service(uri, service)
puts "Started!"

DRb.thread.join