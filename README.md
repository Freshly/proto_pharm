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

## Let's go Pharming!

Before we dive into the code - all examples below will refer to a gRPC service called `hello.hello` with (among others) an rpc endpoint `Hello` which receives the proto `hello.HelloRequest` and responds with the proto `hello.HelloResponse`.

The local variable `client` is defined as follows:
```ruby
client = Hello::Hello::Stub.new('localhost:8000', :this_channel_is_insecure)
``` 

See full definition of protocol buffers and gRPC generated code in [spec/examples/hello](https://github.com/Freshly/proto_pharm/tree/master/spec/examples/hello).

## RSpec Usage

To take full advantage of the helpers listed here, make sure to add the following to your `spec_helper.rb` or `rails_helper.rb`:
```ruby
require 'proto_pharm/rspec'
```

### Stubbing service responses

For the simplest use case, stub a response value for a given rpc endpoint like so:
```ruby
allow_grpc_service(Hello::Hello)
  .to receive_rpc(:hello)
  .and_return(msg: 'Hello!')

client.hello(Hello::HelloRequest.new(msg: 'Hello?')) # => <Hello::HelloResponse: msg: "Hello!">
```

To stub a response for a specific request received:
```ruby
allow_grpc_service(Hello::Hello)
  .to receive_rpc(:hello)
  .with(msg: 'Hola?')
  .and_return(msg: 'Bienvenidos!')

client.hello(Hello::HelloRequest.new(msg: 'Hello?')) # => Sent to network
client.hello(Hello::HelloRequest.new(msg: 'Hola?')) # => <Hello::HelloResponse: msg: "Bienvenidos!">
```

Stub a failure response:
```ruby
allow_grpc_service(Hello::Hello)
  .to receive_rpc(:hello)
  .and_fail_with(:not_found, "No one's here...")

client.hello(Hello::HelloRequest.new(msg: 'Hello?')) # => <GRPC::NotFound: 5:No one's here...>
```

Stub failure metadata:
```ruby
allow_grpc_service(Hello::Hello)
  .to receive_rpc(:hello)
  .and_fail_with(:not_found, metadata: { people_here: :none })

begin
  client.hello(Hello::HelloRequest.new(msg: 'Hello?'))
rescue => e
  e  # => <GRPC::NotFound: 5:>
  e.metadata # => {:people_here=>"none"}
end
```
Note here that the `"none"` value is a string - all metadata values will be cast as strings on response to emulate actual gRPC behavior.

Or, if you just want the call to fail and don't care about the failure type, it defaults to `:invalid_argument`:
```ruby
allow_grpc_service(Hello::Hello).to receive_rpc(:hello).and_fail
client.hello(Hello::HelloRequest.new(msg: 'Hello?')) # => <GRPC::InvalidArgument: 3:>

# Or with some metadata...

allow_grpc_service(Hello::Hello).to receive_rpc(:hello).and_fail_with(metadata: { some: :meta_here })
client.hello(Hello::HelloRequest.new(msg: 'Hello?')) # => You get the picture
```

#### Asserting RPC reception

ProtoPharm also adds a matcher to assert rpc reception. For example:\
```ruby
allow_grpc_service(Hello::Hello)
  .to receive_rpc(:hello)
  .and_return(msg: 'Hello!')

client.hello(Hello::HelloRequest.new(msg: 'Hello?'))
expect(Hello::Hello).to have_received_rpc(:hello)
```

You can also assert the arguments received:
```ruby
expect(Hello::Hello).to have_received_rpc(:hello).with(msg: 'Hello?')
```

### Argument Flexibility
You may have noticed that the above examples stub proto objects without specifying the proto type (for example, `.and_return(msg: 'Hello!')`). No `Hello::HelloRequest.new`s in sight! Both `with` and `and_return` will happily accept protos, hashes or keyword args. If you pass an invalid key to a stub method, you'll get an error:
```ruby
allow_grpc_service(Hello::Hello).to receive_rpc(:hello).and_return(message: "Is this thing on?")
# => ArgumentError: Unknown field name 'message' in initialization map entry.
```

Happy stubbing!

## Usage for Minitest etc.

### Stubbed request based on path and with the default response

```ruby
ProtoPharm.stub_request("/hello.hello/Hello").to_return(Hello::HelloResponse.new(msg: 'test'))

client.hello(Hello::HelloRequest.new(msg: 'hi')) # => Hello::HelloResponse.new(msg: 'test')
```

### Stubbing requests based on path and request

```ruby
ProtoPharm.stub_request("/hello.hello/Hello").with(Hello::HelloRequest.new(msg: 'hi')).to_return(Hello::HelloResponse.new(msg: 'test'))

client.hello(Hello::HelloRequest.new(msg: 'hello')) # => send a request to server
client.hello(Hello::HelloRequest.new(msg: 'hi'))    # => Hello::HelloResponse.new(msg: 'test') (without any requests to server)
```

### Stubbing per-action requests based on parametrized request

```ruby
ProtoPharm.stub_grpc_action(Hello::Hello::Service, :Hello).with(msg: 'hi').to_return(msg: 'test')

client.hello(Hello::HelloRequest.new(msg: 'hello')) # => send a request to server
client.hello(Hello::HelloRequest.new(msg: 'hi'))    # => Hello::HelloResponse.new(msg: 'test') (without any requests to server)

```

### You can user either proto objects or hash for stubbing requests

```ruby
ProtoPharm.stub_grpc_action(Hello::Hello::Service, :Hello).with(Hello::HelloRequest.new(msg: 'hi')).to_return(msg: 'test')
# or
ProtoPharm.stub_grpc_action(Hello::Hello::Service, :Hello).with(msg: 'hi').to_return(Hello::HelloResponse.new(msg: 'test'))

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

### Stubbing Failures

Specific gRPC failure codes can be stubbed with metadata
```ruby
ProtoPharm.
  stub_grpc_action(Hello::Hello::Service, :Hello).
    with(Hello::HelloRequest.new(msg: 'hi')).
    to_fail_with(:invalid_argument, "This message is optional", metadata: { put: :your, metadata: :here })
    
begin 
  client.hello(Hello::HelloRequest.new(msg: 'hi'))
rescue => e
  e # => #<GRPC::InvalidArgument: 3:This message is optional>
  e.metadata # => { :put => :your, :metadata => here }
```

By default, The failure code is `invalid_argument` and the message is optional - so if the code under test doesn't rely on those for any downstream behavior, you can simplify the stubbing by passing only metadata:
```ruby
stub_grpc_action(Hello::Hello::Service, :Hello).
  to_fail_with(metadata: { important_things: [:in, :here] })
client.hello(Hello::HelloRequest.new(msg: 'hi')) 
# => #<GRPC::InvalidArgument: 3:>
exception.metadata 
# => { :important_things => [:in, :here] }

```
...or by passing nothing at all:
```ruby
stub_grpc_action(Hello::Hello::Service, :Hello).to_fail
client.hello(Hello::HelloRequest.new(msg: 'hi')) 
# => #<GRPC::InvalidArgument: 3:>
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
