# frozen_string_literal: true

require 'proto_pharm'
require 'proto_pharm/dsl'

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

  config.include ProtoPharm::DSL
end
