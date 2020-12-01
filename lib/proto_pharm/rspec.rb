# frozen_string_literal: true

require "rspec"

require_relative "../proto_pharm"

require_relative "rspec/receive_expectation"
require_relative "rspec/service_stub_proxy"

require_relative "rspec/dsl"
require_relative "rspec/matchers/have_received_rpc"

RSpec.configure do |config|
  config.before(:suite) do
    ProtoPharm.enable!
  end

  config.after(:suite) do
    ProtoPharm.disable!
  end

  config.after(:each) do
    ProtoPharm.reset!
  end

  config.include ProtoPharm::RSpec::DSL
  config.include ProtoPharm::RSpec::Matchers
end
