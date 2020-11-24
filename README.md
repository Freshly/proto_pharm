# ProtoPharm

Stub your gRPCs with lab-grown proto objects. Life is better on the pharm.

Built on a great foundation by @ganmacs at [ganmacs/grpc_mock](https://github.com/ganmacs/grpc_mock).

## Installation

Add this line to your application's Gemfile in the development/test group:

```ruby
gem 'proto_pharm'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install proto_pharm

## Usage

If you use [RSpec](https://github.com/rspec/rspec), add the following code to spec/spec_helper.rb:

```ruby
require 'proto_pharm/rspec'
```

## Examples

See definition of protocol buffers and gRPC generated code in [spec/exmaples/hello](https://github.com/Freshly/proto_pharm/tree/master/spec/examples/hello)

### Stubbed request based on path and with the default response

```ruby
ProtoPharm.stub_request("/hello.hello/Hello").to_return(Hello::HelloResponse.new(msg: 'test'))

client = Hello::Hello::Stub.new('localhost:8000', :this_channel_is_insecure)
client.hello(Hello::HelloRequest.new(msg: 'hi')) # => Hello::HelloResponse.new(msg: 'test')
```

### Stubbing requests based on path and request

```ruby
ProtoPharm.stub_request("/hello.hello/Hello").with(Hello::HelloRequest.new(msg: 'hi')).to_return(Hello::HelloResponse.new(msg: 'test'))

client = Hello::Hello::Stub.new('localhost:8000', :this_channel_is_insecure)
client.hello(Hello::HelloRequest.new(msg: 'hello')) # => send a request to server
client.hello(Hello::HelloRequest.new(msg: 'hi'))    # => Hello::HelloResponse.new(msg: 'test') (without any requests to server)
```

### Stubbing per-action requests based on parametrized request

```ruby
ProtoPharm.stub_grpc_action(Hello::Hello::Service, :Hello).with(msg: 'hi').to_return(msg: 'test')

client = Hello::Hello::Stub.new('localhost:8000', :this_channel_is_insecure)
client.hello(Hello::HelloRequest.new(msg: 'hello')) # => send a request to server
client.hello(Hello::HelloRequest.new(msg: 'hi'))    # => Hello::HelloResponse.new(msg: 'test') (without any requests to server)

```

### You can user either proto objects or hash for stubbing requests

```ruby
ProtoPharm.stub_grpc_action(Hello::Hello::Service, :Hello).with(Hello::HelloRequest.new(msg: 'hi')).to_return(msg: 'test')
# or
ProtoPharm.stub_grpc_action(Hello::Hello::Service, :Hello).with(msg: 'hi').to_return(Hello::HelloResponse.new(msg: 'test'))

client = Hello::Hello::Stub.new('localhost:8000', :this_channel_is_insecure)
client.hello(Hello::HelloRequest.new(msg: 'hello')) # => send a request to server
client.hello(Hello::HelloRequest.new(msg: 'hi'))    # => Hello::HelloResponse.new(msg: 'test') (without any requests to server)
```

### Real requests to network can be allowed or disabled

```ruby
client = Hello::Hello::Stub.new('localhost:8000', :this_channel_is_insecure)

ProtoPharm.disable_net_connect!
client.hello(Hello::HelloRequest.new(msg: 'hello')) # => Raise NetConnectNotAllowedError error

ProtoPharm.allow_net_connect!
Hello::Hello::Stub.new('localhost:8000', :this_channel_is_insecure) # => send a request to server
```

### Raising errors

**Exception declared by class**

```ruby
ProtoPharm.stub_request("/hello.hello/Hello").to_raise(StandardError)

client = Hello::Hello::Stub.new('localhost:8000', :this_channel_is_insecure)
client.hello(Hello::HelloRequest.new(msg: 'hi')) # => Raise StandardError
```

**or by exception instance**

```ruby
ProtoPharm.stub_request("/hello.hello/Hello").to_raise(StandardError.new("Some error"))
```

**or by string**

```ruby
ProtoPharm.stub_request("/hello.hello/Hello").to_raise("Some error")
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Freshly/proto_pharm. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
