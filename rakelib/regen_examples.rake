# frozen_string_literal: true

task :regen_examples do
  system <<~BASH
    grpc_tools_ruby_protoc \
      -I ./spec/examples/hello \
      --ruby_out=./spec/examples/hello \
      --grpc_out=./spec/examples/hello \
      spec/examples/hello/hello.proto
  BASH
end
