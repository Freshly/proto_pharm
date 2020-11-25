# frozen_string_literal: true

RSpec.describe ProtoPharm::RequestPattern do
  let(:request_pattern) { described_class.new(path) }

  let(:path) { "test_path" }

  describe "#path" do
    subject { request_pattern.path }

    it { is_expected.to eq path }
  end

  describe "#request" do
    subject { request_pattern.request }

    context "when request has not been set" do
      it { is_expected.to be_nil }
    end

    context "when request has been set" do
      let(:request) { double }

      before { request_pattern.with(request) }

      it { is_expected.to eq request }
    end
  end

  describe "#block" do
    subject { request_pattern.block }

    context "when block has not been set" do
      it { is_expected.to be_nil }
    end

    context "when block has been set" do
      let(:block) { -> {} }

      before { request_pattern.with(&block) }

      it { is_expected.to eq block }
    end
  end

  describe "#with" do
    context "with no argument" do
      it "raises an error" do
        expect { request_pattern.with }.to raise_error(ArgumentError)
      end
    end
  end

  describe "match?" do
    let(:request) { double(:request) }

    it { expect(request_pattern.match?(path, request)).to eq(true) }

    context "when call with" do
      it "reutrns true" do
        request_pattern.with(request)
        expect(request_pattern.match?(path, request)).to eq(true)
      end

      context "when request is not same value" do
        it "reutrns false" do
          request_pattern.with(double(:request1))
          expect(request_pattern.match?(path, request)).to eq(false)
        end
      end

      context "with block returning ture" do
        it "reutrns false" do
          request_pattern.with(request) { |_| true }
          expect(request_pattern.match?(path, request)).to eq(true)
        end
      end

      context "with block returning false" do
        it "reutrns false" do
          request_pattern.with(request) { |_| false }
          expect(request_pattern.match?(path, request)).to eq(false)
        end
      end
    end
  end
end
