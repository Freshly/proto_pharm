# frozen_string_literal: true

require "rspec"

require_relative "../proto_pharm"
require_relative "dsl"
require_relative "matchers/rspec"

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
  config.include ProtoPharm::Matchers::RSpec
end
