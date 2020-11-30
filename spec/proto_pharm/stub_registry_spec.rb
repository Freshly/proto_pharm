# frozen_string_literal: true

RSpec.describe ProtoPharm::StubRegistry do
  let(:registry) { described_class.new }

  let(:path) { Faker::Lorem.words.join("/") }
  let(:request) { double }
  let(:response) { double }

  let(:request_stub) { ProtoPharm::RequestStub.new(path).with(request).to_return(response) }

  describe "#register_request_stub" do
    subject(:register_request_stub) { registry.register_request_stub(request_stub) }

    it { is_expected.to equal request_stub }

    it "adds the stub to the registry" do
      register_request_stub
      expect(registry.request_stubs[path].first).to eq request_stub
    end

    context "when a stub already exists for the path" do
      let(:another_request_stub) { ProtoPharm::RequestStub.new(path).with(request).to_return(response) }

      before do
        registry.register_request_stub(another_request_stub)
        register_request_stub
      end

      it "supercedes the existing stub" do
        expect(registry.request_stubs[path].first).to eq request_stub
        expect(registry.request_stubs[path].first).not_to eq another_request_stub
      end
    end
  end

  describe "#find_request_matching" do
    subject { registry.find_request_matching(path, request) }

    context "when nothing is stubbed for the path" do
      it { is_expected.to be_nil }
    end

    context "when something is stubbed for the path" do
      before { registry.register_request_stub(request_stub) }

      it { is_expected.to eq request_stub }

      context "when multiple things are stubbed for the path" do
        let(:another_request_stub) { ProtoPharm::RequestStub.new(path).with(request).to_return(response) }

        before { registry.register_request_stub(another_request_stub) }

        it { is_expected.to eq another_request_stub}

        it { is_expected.not_to eq request_stub }
      end
    end
  end
end
