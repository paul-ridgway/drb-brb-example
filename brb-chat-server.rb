#!/usr/bin/env ruby

require 'brb'
require 'pp'

class ChatServer

  def initialize
    @clients = {}
    @names = {}
  end
  
  def send_message(id, name, message)
    puts "SERVER: We got a message from #{id} / #{@names[id]}: #{message}"
    broadcast id, name, message
  end

  def method_missing(m, *args, &block)  
    puts "Oops! A client tried to call: #{m}"
    "There's no method called #{m} here -- please try again."  
  end

  def start
    Thread.abort_on_exception = true
    port = 5555
    BrB::Service.start_service(object: self, verbose: true, host: 'localhost', port: port) do |event, client|
      on_connection_event(event, client)
    end
    puts "Listening on port #{port}"
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
    id = 'unknown_id'
    name = 'unknown_name'
    id = client.client_id_block if client.method_missing(:send_block, :respond_to?, :client_id)
    name = client.name_block if client.method_missing(:send_block, :respond_to?, :name)

    @clients[client] = id
    @names[id] = name

    broadcast id, "Server", "#{name} has joined the group"
    puts "Client #{id} registered. #{client_summary}"
  end

  def unregister_client(client)
    id = @clients[client]
    name = @names[id]
    @clients.delete(client)

    broadcast id, "Server", "#{name} has left the group"
    puts "Client #{id} unregistered. #{client_summary}"
  end

  def client_summary
    "Clients: #{@clients.map{|_, v| v}.join(', ')}"
  end

end


ChatServer.new.start