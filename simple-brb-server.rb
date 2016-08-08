#!/usr/bin/env ruby

require 'brb'

class ExposedCoreObject
  
  def simple_api_method
    puts "#{Thread.current} > In simple api method, now sleeping"
    yield if block_given?
    sleep 1
    puts "#{Thread.current} > Done sleeping in simple api method, return"
    return 'OK'
  end
  
  def simple_long_api_method
    puts "#{Thread.current} > In simple long api method, now sleeping"
    sleep 10
    puts "#{Thread.current} > Done sleeping in long api method, return"
    return 'OK LONG'
  end

  def add(a, b)
    result = a + b
    puts "[#{@name}] Adding: #{a} + #{b} = #{result}"
    return result
  end
    
  
end

Thread.abort_on_exception = true

port = 5555
host = 'localhost'

puts " > Starting the core on brb://#{host}:#{port}"
BrB::Service.start_service(:object => ExposedCoreObject.new, :verbose => true, :host => host, :port => port)
EM.reactor_thread.join