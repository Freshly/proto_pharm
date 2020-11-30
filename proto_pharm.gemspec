# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative "lib/proto_pharm/version"

Gem::Specification.new do |spec|
  spec.name          = "proto_pharm"
  spec.version       = ProtoPharm::VERSION
  spec.authors       = ["Yuta Iwama", "Allen Rettberg"]
  spec.email         = ["ganmacs@gmail.com", "allen.rettberg@freshly.com"]

  spec.summary       = "Stub your gRPCs with lab-grown proto objects"
  spec.description   = "Stub your gRPCs with lab-grown proto objects"
  spec.homepage      = "https://github.com/Freshly/proto_pharm"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 5.2.0"
  spec.add_dependency "grpc", ">= 1.12.0", "< 2"
  spec.add_dependency "short_circu_it"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "faker"
  spec.add_development_dependency "grpc-tools"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspice"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "spicerack-styleguide"
end
