require 'spec_helper'
require 'spf/query/ip'

describe SPF::Query::IP do
  let(:address)     { '127.0.0.1' }
  let(:cidr_length) { 24          }

  subject { described_class.new(address,cidr_length) }

  describe "#to_s" do
    context "when there is a cidr length" do
      it "should add the cidr length suffix" do
        expect(subject.to_s).to be == "#{address}/#{cidr_length}"
      end
    end

    context "when there is no cidr length" do
      subject { described_class.new(address) }

      it "should return the address" do
        expect(subject.to_s).to be == address
      end
    end
  end
end
