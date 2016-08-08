#!/usr/bin/env ruby

require 'brb'
require 'securerandom'

class ChatClient

	def initialize
		@client_id = SecureRandom.uuid
		@name = ''
	end

	def client_id
		@client_id
	end

	def receive_message(sender, message)
		puts "#{sender}: #{message}"
	end

	def name
		@name
	end

	def start
		@name = prompt("What's your name")
		core
		
		while true
			message = prompt("Message")
			puts "You: #{message}"
			core.send_message_block @client_id, @name, message
		end
	end 

	private
	def prompt(message)
		result = ''
		while result.to_s == ''
			print "#{message}? "
			result = gets.strip
		end
		result
	end

	def core		
		if (!defined? @core)
			puts "Core not defined, connecting..."
			@core = connect
		end
		while !@core.active?
			puts "Core not active, reconnecting..."
			sleep 1
			@core = connect
		end
		@core
	end

	def connect
		BrB::Tunnel.create(self, "brb://localhost:5555", :verbose => true)
	end

end


client = ChatClient.new.start
