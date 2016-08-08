#!/usr/bin/env ruby

require 'brb'
require 'pp'
require 'securerandom'

module Kernel
  remove_method :exec
  remove_method :system
  remove_method :`
end

module BrB
  module Tunnel
    module Shared

      def treat_request(obj)
        puts "treat_request"
        if obj.size == 2
          new_brb_in_request(obj[1])
        else
          new_brb_in_request(obj[1], *(obj.last))
        end
        rescue => e
          puts "Chaos: #{e}"
      end

    end
  end
end

class ChatServer

  def initialize
    @clients = {}
    @names = {}
    @started = false
  end
  
  def send_message(id, message)
    name = @names[id]
    puts "SERVER: We got a message from #{id} / #{name}: #{message}"
    broadcast id, name, message
  end

  def method_missing(m, *args, &block)  
    puts "Oops! A client tried to call: #{m}"
    "There's no method called #{m} here -- please try again."  
  end

  def ping
    "pong @ #{Time.new}"
  end

  def start
    if @started
      puts "Already started!"
      return
    end
    
    Thread.abort_on_exception = true
    port = 5555
    EM.error_handler { |e| puts "Error raised during event loop: #{e.message}" }
    BrB::Service.start_service(object: self, verbose: true, host: 'localhost', port: port) do |event, client|
      on_connection_event(event, client)
    end
    puts "Listening on port #{port}"
    @started = true
    EM.reactor_thread.join
  end

  private
  def broadcast(id, from, message) 
    @clients.select { |_, client_id| client_id != id }.each { |client, _| client.receive_message(from, message) }
  end

  def on_connection_event(event, client)
    if event == :register
      register_client client
    else
      unregister_client client
    end
  rescue => e
    puts "Error: #{e}"
  end

  def register_client(client)
    uid = SecureRandom.uuid
    id = "unknown_id-#{uid}"
    name = "unknown_name-#{uid}"
    id = client.client_id_block if client.method_missing(:send_block, :respond_to?, :client_id)
    name = client.name_block if client.method_missing(:send_block, :respond_to?, :name)

    @clients[client] = id
    @names[id] = name

    puts "Client #{id} registered. #{client_summary}"
    broadcast id, "Server", "#{name} has joined the group"
  end

  def unregister_client(client)
    id = @clients[client]
    name = @names[id]
    @clients.delete(client)

    puts "Client #{id} unregistered. #{client_summary}"
    broadcast id, "Server", "#{name} has left the group"
  end

  def client_summary
    "Clients: #{@clients.map{|_, v| v}.join(', ')}"
  end

end


ChatServer.new.start