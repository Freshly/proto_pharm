# frozen_string_literal: true

RSpec.describe ProtoPharm::StubRegistry do
  let(:registry) { described_class.new }

  let(:path) { "service/method_name" }
  let(:response) { double }

  let(:request_stub) do
    instance_double(ProtoPharm::RequestStub, match?: true, path: path, response: response)
  end

  # TODO: actually write specs for this class. This is...bad.
  it "registers and responses" do
    expect(registry.register_request_stub(request_stub)).to eq(request_stub)
    expect(registry.response_for_request(path, double(:request))).to eq(response)
  end
end
