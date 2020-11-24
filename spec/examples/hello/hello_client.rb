# frozen_string_literal: true

require_relative './hello_services_pb'

class HelloClient
  STUB_URL = 'localhost:8000'

  def client
    @client ||= Hello::Hello::Stub.new(STUB_URL, :this_channel_is_insecure)
  end

  def send_message(msg, client_stream: false, server_stream: false, return_op: false)
    if client_stream && server_stream
      m = Hello::HelloStreamRequest.new(msg: msg)
      client.hello_stream([m].to_enum)
    elsif client_stream
      m = Hello::HelloStreamRequest.new(msg: msg)
      client.hello_client_stream([m].to_enum)
    elsif server_stream
      m = Hello::HelloRequest.new(msg: msg)
      client.hello_server_stream(m)
    else
      m = Hello::HelloRequest.new(msg: msg)
      client.hello(m, return_op: return_op)
    end
  end
end
